# MyHash*
###### *not secure in ANY way*
```
MyHash()
>> e>vlK:Ic"Y$6^JeE
```

### Why
I created this for use within web development as a test function for SQL input escaping, as depending on certain adjustable factors, some *very nasty* ascii symbols can be outputted. If your forms can appropriately handle these types of strings, consider yourself *somewhat* relieved.

### How
-
Hash uses a comically impractical implementation of an S-table in the form of a CSV, which exists only as a relic of a previous version. The justification for this elementary gaffe: *increased lookup time slows down bad guys -___-*
```
% TURN stuff INTO A STRING
>> long STR

% CREATION OF HEXADECIMAL STRING FROM INPUT & PEPPER
>> long string is salted and converted to HEX

% INITIALIZE STORED STRING
>> genesis block is loaded

% MERKLE-DAMGARD FUNCTION
>> hash is updated with n blocks

% FINISHING FUNCTION
>> resulting numbers are scrubbed and formatted
```

### Mechanism
-
A traditional SHA architecture is employed, where input blocks are structured in a fixed length with padding agnostically inserted.

### Recipes
```
% accepts arbitrary input types

MyHash('hello, world!')
MyHash(1234567890)
MyHash(0.31415926)
MyHash(1,0,2,4,7,9)
```

### Fingerprints
```
>> MyHash('hello, world!')
ans =
    'RJ"K$2Q(&&k(&nuG'

>> MyHash('hello, world')
ans =
    'b0:66tr>b8{"q*O6'

>> MyHash('hello,world!')
ans =
    '6V~U6IB$tG62^Vm"'
```
