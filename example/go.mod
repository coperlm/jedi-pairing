module github.com/ucbrise/jedi-pairing-example

go 1.21

replace github.com/ucbrise/jedi-pairing => ../

require github.com/ucbrise/jedi-pairing v0.0.0-00010101000000-000000000000

require (
	golang.org/x/crypto v0.28.0 // indirect
	golang.org/x/sys v0.26.0 // indirect
)
