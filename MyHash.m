function H = MyHash(stuff,BlockSize)
% *** NOT FOR PRODUCTION USE ***
% *** ONLY USE FOR FUN ***
% H = MyHash(stuff,BlockSize)
% RETURNS HASH OF TYPE char ... DEFAULT LENGTH = 16
switch nargin
    case 0 % NO ARG -> TREAT AS EMPTY STRING
        stuff = '';
        BlockSize = 16;
    case 1
        BlockSize = 16;
    otherwise
end
PrimeGapList = [];

% TURN stuff INTO A STRING
s = StuffToString(stuff);

% CREATION OF HEXADECIMAL STRING FROM INPUT & PEPPER
Hexa = pepper(s,BlockSize);

% INITIALIZE STORED STRING
Stored = InitStored(Hexa,BlockSize);

% MERKLE-DAMG�RD FUNCTION
rawHash = MerkleDamgard(Hexa,Stored,BlockSize);

% FINISHING FUNCTION
H = finalizehash(rawHash);


% ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ FUNCTIONS ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ %
    function s = StuffToString(stuff)
        switch class(stuff)
            case 'char'
                s = stuff;
            case 'double'
                s = num2str(stuff);
            case 'single'
                s = num2str(stuff);
            case 'logical'
                s = num2str(stuff);
            case 'cell'
                s = char(stuff);
            case 'struct'
                disp('STRUCTS NOT SUPPORTED');
                return
        end
    end

    function hexstring = pepper(s,BlockSize)  %%%%% BOTTLENECK %%%%%
        % compute imporant variables
        obs = round(power(pi*log10(length(s)+1),2))+BlockSize;  % OBSCURING FACTOR
        padlen = abs(BlockSize - mod(obs,BlockSize)); % PAD LENGTH
        % append with data (obs * BlockSize) + padlen
        NumberOfPadElements = obs * BlockSize;
        Reach = (power(obs,2)*BlockSize);
        PrimeGapList = csvread('PrimeGapList.csv',Reach,0);
        pg = PrimeGapList(padlen:obs:(power(obs,2)*BlockSize));
        if length(pg)~=NumberOfPadElements
            disp('ERROR IN PAD FUNCTION');
            disp(length(pg));
            disp(NumberOfPadElements);
        end
        % convert columns to single row
        padrow = col2row(num2str(pg));   %* need to ensure to only have 2digit elements
        fullpad = col2row(dec2hex(padrow));

        x = col2row(dec2hex(fullpad));
        y = col2row(dec2hex(s));

        % combine the pepper array with s
        endindex = mod(length(fullpad)+length(dec2hex(s)),BlockSize*2); %..rly length
        hexstring = [ x(1:end-(2*endindex))   y];
        % check to make sure final pad is perfect length
        if mod(length(hexstring),BlockSize*2)
            disp('ERROR IN HEX PAD CREATION');
        end
        hexstring;
    end

    function rawHash = MerkleDamgard(Hexa,Stored,BlockSize)
        Stored;
        for i = 1:(length(Hexa)/BlockSize)
            Block = Hexa(1:BlockSize);
            Hexa(1:BlockSize) = [];
            S = double(uint8(Stored)); B = double(uint8(Block));
            Cycles = 0;

            while Cycles < 3 % round(mean(B))

                for x = 1:numel(Stored)
                    tot = 0;
                    Plus = x:2:BlockSize;
                    Minus = x+1:2:BlockSize;

                    for y = 1:numel(Plus)
                        idx = Plus(y);
                        tot = tot + B(idx);
                    end

                    if Minus
                        for z = 1:numel(Minus)
                            idx = Minus(z);
                            tot = tot - B(idx);
                        end
                    end
                    tot = abs(tot + (S(x)));
                    tot = str2num(flip(num2str(tot)));
                    S(x) = mod(tot(1),255);
                end
                Stored = char(flip(S));
                Cycles = Cycles + 1;
            end
        end
        rawHash = Stored;
    end

    function H = finalizehash(stored)
        NotAllowed = [127]; % 127 BAD!!!!
        % 69:90 is upper letters    97:122 is lower

        UI8orig = double(uint8(stored));
        UI8smooth = round(smoothdata(uint8(stored))); %*
        h = UI8orig;
        % make sure numbers are in range for ui8
        for i = 1:length(h)
            if lt(h(i),0) || gt(h(i),255)
                switch sign(h(i))
                    case 1
                        h(i) = 255;
                    case -1
                        h(i) = 0;
                end
            end
        end

        % folding function
        while any(lt(h,32))
            for i = 1:length(h)
                if lt(h(i),64)
                    h(i) = h(i) * 2;
                    if lt(h(i),32)
                        h(i) = h(i) + 32;
                    end
                elseif gt(h(i),128)
                    h(i) = round(h(i) / 2);
                    if gt(h(i),160)
                        h(i) = h(i) - 32;
                    end
                else
                    continue
                end
            end
        end

        % replace restricted number(s), since the output is agnostic of
        % ascii equivalent of integers. We obviously want to omit anything below 31
        % as these are system calls, as well as any characters that may cause fatal errors.
        if ~isempty(find(NotAllowed==h))
            h(find(NotAllowed==h)) = 111;
        end
        H = char(uint8(h));
    end

    function Stored = InitStored(Hexa,BlockSize)
        Stored = flip(Hexa(end-BlockSize+1:end));
    end

    function row = col2row(column)
        row = [];
        for i = 1:length(column)
            row = [row column(i,:)];
        end
        row;
    end
end
% end of script
