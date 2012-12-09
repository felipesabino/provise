# Provise

CLI used to change the provisioning profile of an iOS App (.ipa file). Also makes possible changing the bundle identifier if the new provisioning has a different one.

## Installation
```
$ gem install provise
```

## Usage

To simply change the provisioning

```
$ resign ipa -i Application.ipa -p foo/bar.mobileprovision -c \"iPhone Distribution: Bla Bla\"
```

To change the peovisionig and also the bundle identifier
```
$ resign ipa -i Application.ipa -p foo/bar.mobileprovision -c "iPhone Distribution: Bla Bla" -b br.com.new.bundle.identifier
```

## Reference

Based on Erik's (http://stackoverflow.com/users/487353/erik) original answer at 
http://stackoverflow.com/a/6921689/429521


## Contact

Felipe Sabino

- http://github.com/felipesabino
- http://twitter.com/felipesabino
- http://stackoverflow.com/users/429521/felipe-sabino
- felipe@sabino.me

## License

Provise is available under the MIT license. See the LICENSE file for more info.
