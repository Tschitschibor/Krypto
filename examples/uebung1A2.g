Read( Concatenation(
  GAPInfo.RootPaths[1],
  "pkg/Krypto/gap/Vigenere.g" ) );
  
s := "Ich muss Sie deshalb dringen bitten von Geschenken in diesem Jahr ausnahmsweise einmal abzusehen";
keyword := "tageszeitung";
ct := encryptVigenere( keyword, s );
table := attackVigenere( ct );
