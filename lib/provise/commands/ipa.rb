command :ipa do |c|

	c.syntax = '$ resign ipa [options]'
	c.summary = 'Generate a new .ipa file with provisioning profile provided'
	c.description = ''

	c.example 'example', 'resign ipa -i Application.ipa -p foo/bar.mobileprovision -c \"iPhone Distribution: Bla Bla\"'
	c.example 'example with bundle identifier change', 'resign ipa -i Application.ipa -p foo/bar.mobileprovision -c "iPhone Distribution: Bla Bla" -b br.com.new.bundle.identifier'

	c.option '-i', '--ipa IPA', 'Path to the original .ipa file'
	c.option '-p', '--provisioning PROVISIONING', 'Path to the provisioning profile file (generally a .mobileprovision file)'
	c.option '-c', '--certificate CERTIFICATE', 'Name of the Distribution Certificate name (copy it from Certificate detail\'s "Common name" at the Keychain Access)'
	c.option '-b', '--bundle BUNDLE', 'The new bundle identifier in case your new provisioning has a differente one'
	c.option '-q',	'--quiet',	'Supress warnings and info messages'

	c.action do |args, options|

		# getting  parameters

		@ipa_path = options.ipa
		@provisioning_path = options.provisioning
		@certificate_name = options.certificate
		@new_bundle_identifier = options.bundle

		return unless validate_params!

		# unzip IPA file to manipulate the plist and the certificate resources

		@ipa_filename = File.basename @ipa_path, File.extname(@ipa_path)
		@tmp_dir = "#{Dir.tmpdir}/resign"

		say "Unziping #{@ipa_filename}.ipa file to a temp dir" unless options.quiet
		system "rm -rf #{@tmp_dir}"
		system "mkdir #{@tmp_dir}"
		system "unzip -q #{@ipa_path} -d #{@tmp_dir}"


		say "Removing old code signatures" unless options.quiet
		system "rm -rf #{@tmp_dir}/Payload/*.app/_CodeSignature #{@tmp_dir}/Payload/*.app/CodeResources"

		if @new_bundle_identifier
			say "Changing bundle identifier to #{@new_bundle_identifier}" unless options.quiet
			system "/usr/libexec/PlistBuddy -c \"Set :CFBundleIdentifier #{@new_bundle_identifier}\" #{@tmp_dir}/Payload/*.app/Info.plist"
		end

		say "Replacing provisioning profile" unless options.quiet
		system "cp #{@provisioning_path} #{@tmp_dir}/Payload/*.app/embedded.mobileprovision"

		say "Replacing existing signatures" unless options.quiet
		system "/usr/bin/codesign -f -s \"#{@certificate_name}\" --resource-rules #{@tmp_dir}/Payload/*.app/ResourceRules.plist #{@tmp_dir}/Payload/*.app"


		new_ipa_file = "#{@ipa_filename}.resigned.ipa"

		say "Packing resigned ipa file to #{new_ipa_file}" unless options.quiet

		# to zip correctly, it must go to the correct path
		script_folder = Dir.pwd.gsub(" ", "\\ ")
		Dir.chdir(@tmp_dir) do
			system "zip -qr #{script_folder}/#{new_ipa_file} ./Payload/"
		end

		say "Cleaning temp folders" unless options.quiet
		system "rm -rf #{@tmp_dir}"

		say "done." unless options.quiet

	end

	private

	def validate_params!

		say_error "Path to .ipa file is reqired" unless @ipa_path
		say_error "Path to provisioning profile is required" unless @provisioning_path
		say_error "Name of new certificate is required" unless @certificate_name

		return true if @ipa_path and @provisioning_path and @certificate_name

	end

end