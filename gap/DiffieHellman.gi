# Diffie-Hellmann key exchange protocol (2.5.4)
#
# prime p, primitive root a (mod p) are public
# Alice chooses integer r with 0 <= r <= p-2,
# calculates c = a^r mod p. Sends c to Bob.
# Bob chooses integer s with 0 <= s <= p-2,
# calculates d = a^s mod p. Sends d to Alice.
# Alice calculates d^r mod p = (a^s mod p)^r mod p
# = a^(rs) mod p.
# Bob calculates c^s mod p = (a^r mod p)^s mod p
# = a^(rs) mod p.
# Both now know the value of a^(rs) mod p.
# This is their common key.
#
# In general: group G, group element g with ord g.
# integers r, s with 0 <= r, s, < ord g.
# group elements c = g^r and d = g^s are sent.
# g^(rs) = c^s = d^r is the common key.
# Adjust accodingly with additive group instead of
# multiplicative group.

Read( Concatenation( GAPInfo.RootPaths[1],
  "pkg/Krypto/gap/EllipticCurve.gi" ) );


