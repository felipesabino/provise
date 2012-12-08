# provise

CLI used to change the provisioning profile of an iOS App (.ipa file). Also makes possible changing the bundle identifier if the new provisioning has a different one.

## Installation

        $ gem install provise

## Usage

To simply change the provisioning

        $ resign ipa -i Application.ipa -p foo/bar.mobileprovision -c \"iPhone Distribution: Bla Bla\"
        
To change the peovisionig and also the bundle identifier

        $ resign ipa -i Application.ipa -p foo/bar.mobileprovision -c "iPhone Distribution: Bla Bla" -b br.com.new.bundle.identifier

