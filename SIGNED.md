##### Signed by https://keybase.io/max
```
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAABCgAGBQJWLEWNAAoJEJgKPw0B/gTfKY0H/0WaRwRYS+EY9eSV2x1Mbrv1
MgYA8gycCTzL77ngJlU75ljw8+SwOw0w63mqsuuMqlOU6240LZ+gabn41C8OxulQ
JUrIfwUTcHiJlftKLQbCPyQqCvmTzfZ79qvp+Al25BwlfJOKkHMlEiWvLIJH6RuE
Ckngt4q1frgIPYpAidSfT0e28cinNGwwQ/BXG7LJUXnrDlId6JHBBp8ViKEaANI9
8HwdKkF7PFeqJewtBoiyVmMTjMEpBmZBdp0FFaFo63oC9voSh6dN9uynZ7VfW1jT
Ap9T6zjvqG3QU3OUFZpLofWD6v9megRZVO+z1bt9NMchuukKbN1YyoJV44Hl8+4=
=9Rvr
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size  exec  file               contents                                                        
            ./                                                                                 
538           .gitignore       6f6b25892efbd684badcacf837371d984a590fb3314d031030d7a08e4dd87c69
1478          LICENSE          84097264a67d2c2d4f1c4c880d040746a71f6c79c129a3950cabbd58f0d1d879
1010          Makefile         954dc86c379e6caf083fb84b5fdf45402ce1d21fb3724d592a60a8303382c853
72            README.md        58f5549b1a777b8dce73301cf358f5721ffad146aad2557e66c2aa3982c71cc5
              lib/                                                                             
4575            encoding.js    61285c9150edb02a2baaea95b59296492f02c84c814011d4fdd605ca99f91170
115             main.js        d7619afe3b8f85aa7c0ec6659280fa1dbe0ea2eb0c100a99777c601affc1846a
72              stream.js      9b768d798dfc690db586acee6c60ee625fab4892f6ac3aaca77b1fb259a29dd3
526           package.json     e742637236ffbbd1d3c8460b39de34e86ebebbc1ca7db5a7b0b2911580dbfbf0
              src/                                                                             
2577            encoding.iced  cda48acb990b191b572279c017be5db178b03a41110e506528a631e4fbb54a4c
40              main.iced      05dd0b59d25cc81315370ae451b4d30f92a9f0a3b8fe51520c4e2cf9aebac99b
0               stream.iced    e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
              test/                                                                            
                files/                                                                         
1648              random.iced  b8f60783718079242fecacd73d9bd270863d4443e4b5c3a1543a580d7b385140
52              run.iced       8e58458d6f5d0973dbb15d096e5366492add708f3123812b8e65d49a685de71c
```

#### Ignore

```
/SIGNED.md
```

#### Presets

```
git      # ignore .git and anything as described by .gitignore files
dropbox  # ignore .dropbox-cache and other Dropbox-related files    
kb       # ignore anything as described by .kbignore files          
```

<!-- summarize version = 0.0.9 -->

### End signed statement

<hr>

#### Notes

With keybase you can sign any directory's contents, whether it's a git repo,
source code distribution, or a personal documents folder. It aims to replace the drudgery of:

  1. comparing a zipped file to a detached statement
  2. downloading a public key
  3. confirming it is in fact the author's by reviewing public statements they've made, using it

All in one simple command:

```bash
keybase dir verify
```

There are lots of options, including assertions for automating your checks.

For more info, check out https://keybase.io/docs/command_line/code_signing