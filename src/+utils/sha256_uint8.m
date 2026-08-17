function hashStr = sha256_uint8(data)
% SHA256_UINT8 Hashes a uint8 array using the SHA-256 algorithm.
%  hashStr = sha256_uint8(data)
%
%  Input:
%   data - A uint8 array to be hashed.
%
%  Output:
%   hashStr - A 64-character hexadecimal string representing the SHA-256 hash of the input data.

if ~isa(data, 'uint8')
    error('Input must be a uint8 array.');
end

data = data(:).';
bitLen = uint64(numel(data)) * 8;

% --- Padding ---
data = [data uint8(128)];

while mod(numel(data) + 8, 64) ~= 0
    data = [data uint8(0)];
end

lenBytes = zeros(1, 8, 'uint8');

for i = 8:-1:1
    lenBytes(i) = uint8(bitand(bitLen, uint64(255)));
    bitLen = bitshift(bitLen, -8);
end

data = [data lenBytes];

% --- Initial hash values ---
H = uint32([
    hex2dec('6a09e667')
    hex2dec('bb67ae85')
    hex2dec('3c6ef372')
    hex2dec('a54ff53a')
    hex2dec('510e527f')
    hex2dec('9b05688c')
    hex2dec('1f83d9ab')
    hex2dec('5be0cd19')
    ]);

% --- Round constants ---
K = uint32([
    hex2dec('428a2f98'); hex2dec('71374491'); hex2dec('b5c0fbcf'); hex2dec('e9b5dba5')
    hex2dec('3956c25b'); hex2dec('59f111f1'); hex2dec('923f82a4'); hex2dec('ab1c5ed5')
    hex2dec('d807aa98'); hex2dec('12835b01'); hex2dec('243185be'); hex2dec('550c7dc3')
    hex2dec('72be5d74'); hex2dec('80deb1fe'); hex2dec('9bdc06a7'); hex2dec('c19bf174')
    hex2dec('e49b69c1'); hex2dec('efbe4786'); hex2dec('0fc19dc6'); hex2dec('240ca1cc')
    hex2dec('2de92c6f'); hex2dec('4a7484aa'); hex2dec('5cb0a9dc'); hex2dec('76f988da')
    hex2dec('983e5152'); hex2dec('a831c66d'); hex2dec('b00327c8'); hex2dec('bf597fc7')
    hex2dec('c6e00bf3'); hex2dec('d5a79147'); hex2dec('06ca6351'); hex2dec('14292967')
    hex2dec('27b70a85'); hex2dec('2e1b2138'); hex2dec('4d2c6dfc'); hex2dec('53380d13')
    hex2dec('650a7354'); hex2dec('766a0abb'); hex2dec('81c2c92e'); hex2dec('92722c85')
    hex2dec('a2bfe8a1'); hex2dec('a81a664b'); hex2dec('c24b8b70'); hex2dec('c76c51a3')
    hex2dec('d192e819'); hex2dec('d6990624'); hex2dec('f40e3585'); hex2dec('106aa070')
    hex2dec('19a4c116'); hex2dec('1e376c08'); hex2dec('2748774c'); hex2dec('34b0bcb5')
    hex2dec('391c0cb3'); hex2dec('4ed8aa4a'); hex2dec('5b9cca4f'); hex2dec('682e6ff3')
    hex2dec('748f82ee'); hex2dec('78a5636f'); hex2dec('84c87814'); hex2dec('8cc70208')
    hex2dec('90befffa'); hex2dec('a4506ceb'); hex2dec('bef9a3f7'); hex2dec('c67178f2')
    ]);

% --- Process each 512-bit block ---
for blockStart = 1:64:numel(data)
    block = data(blockStart:blockStart + 63);

    W = zeros(64, 1, 'uint32');

    for t = 1:16
        j = (t - 1) * 4 + 1;
        W(t) = bitor( ...
            bitor(bitshift(uint32(block(j)), 24), ...
            bitshift(uint32(block(j + 1)), 16)), ...
            bitor(bitshift(uint32(block(j + 2)), 8), ...
            uint32(block(j + 3))));
    end

    for t = 17:64
        s0 = bitxor(bitxor(rotr(W(t - 15), 7), rotr(W(t - 15), 18)), bitshift(W(t - 15), -3));
        s1 = bitxor(bitxor(rotr(W(t - 2), 17), rotr(W(t - 2), 19)), bitshift(W(t - 2), -10));
        W(t) = uint32(mod(uint64(W(t - 16)) + uint64(s0) + uint64(W(t - 7)) + uint64(s1), 2 ^ 32));
    end

    a = H(1); b = H(2); c = H(3); d = H(4);
    e = H(5); f = H(6); g = H(7); h = H(8);

    for t = 1:64
        S1 = bitxor(bitxor(rotr(e, 6), rotr(e, 11)), rotr(e, 25));
        ch = bitxor(bitand(e, f), bitand(bitcmp(e, 'uint32'), g));
        temp1 = add32(h, S1, ch, K(t), W(t));

        S0 = bitxor(bitxor(rotr(a, 2), rotr(a, 13)), rotr(a, 22));
        maj = bitxor(bitxor(bitand(a, b), bitand(a, c)), bitand(b, c));
        temp2 = add32(S0, maj);

        h = g;
        g = f;
        f = e;
        e = add32(d, temp1);
        d = c;
        c = b;
        b = a;
        a = add32(temp1, temp2);
    end

    H(1) = add32(H(1), a);
    H(2) = add32(H(2), b);
    H(3) = add32(H(3), c);
    H(4) = add32(H(4), d);
    H(5) = add32(H(5), e);
    H(6) = add32(H(6), f);
    H(7) = add32(H(7), g);
    H(8) = add32(H(8), h);
end

hashStr = lower(sprintf('%08x', H));
hashStr = reshape(hashStr, 1, []);
end

function y = rotr(x, n)
% 32bit right rotate
y = bitor(bitshift(x, -n), bitshift(x, 32 - n));
end

function y = add32(varargin)
s = uint64(0);

for i = 1:nargin
    s = s + uint64(varargin{i});
end

y = uint32(mod(s, 2 ^ 32));
end
