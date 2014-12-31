require 'shellwords'

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
	c.option '--bundleVersionShort VERSIONSHORT', 'The new release version (CFBundleShortVersionString)'
	c.option '--bundleVersion VERSION', 'The new build version (CFBundleVersion)'
	c.option '--entitlementFile FILE', 'The new entitlement used for creating the signatures'
	c.option '-q',	'--quiet',	'Supress warnings and info messages'

	c.action do |args, options|

		# getting  parameters

		@ipa_path = options.ipa
		@provisioning_path = options.provisioning
		@certificate_name = options.certificate
		@new_bundle_identifier = options.bundle
		@version_short = options.bundleVersionShort
		@bundle_version = options.bundleVersion
		@entitlement_file = options.entitlementFile;

		return unless validate_params!

		# unzip IPA file to manipulate the plist and the certificate resources

		@ipa_filename = File.basename @ipa_path, File.extname(@ipa_path)
		@tmp_dir = "#{Dir.tmpdir}/resign"

		say "Unziping #{@ipa_filename}.ipa file to a temp dir" unless options.quiet
		system "rm -rf #{@tmp_dir}"
		system "mkdir #{@tmp_dir}"
		system "unzip -q #{@ipa_path} -d #{@tmp_dir}"

		@app_filename = Dir["#{@tmp_dir}/Payload/*.app"][0]

		say "Removing old code signatures" unless options.quiet
		system "rm -rf #{@app_filename}/_CodeSignature #{@app_filename}/CodeResources"

		if @new_bundle_identifier
			say "Changing bundle identifier to #{@new_bundle_identifier}" unless options.quiet
			system "/usr/libexec/PlistBuddy -c \"Set :CFBundleIdentifier #{@new_bundle_identifier}\" #{@app_filename}/Info.plist"
		end

		if @version_short
			say "Changing CFBundleShortVersionString to #{@version_short}" unless options.quiet
			system "/usr/libexec/PlistBuddy -c \"Set :CFBundleShortVersionString #{@version_short}\" #{@app_filename}/Info.plist"
		end

		if @bundle_version
			say "Changing CFBundleVersion to #{@bundle_version}" unless options.quiet
			system "/usr/libexec/PlistBuddy -c \"Set :CFBundleVersion #{@bundle_version}\" #{@app_filename}/Info.plist"
		end

		@entitlement_parameter = "";
		if @entitlement_file
			say "Using entitlement file: #{@entitlement_file}" unless options.quiet
			@entitlement_parameter = "--entitlements \"#{@entitlement_file}\""
		end

		say "Replacing provisioning profile" unless options.quiet
		system "cp #{@provisioning_path} #{@app_filename}/embedded.mobileprovision"

		say "Replacing existing signatures" unless options.quiet
		if File.exist? "#{@app_filename}/ResourceRules.plist"
			system "/usr/bin/codesign -f -s \"#{@certificate_name}\" #{@entitlement_parameter} --resource-rules #{@app_filename}/ResourceRules.plist #{@app_filename}"
		else
			system "/usr/bin/codesign -f -s \"#{@certificate_name}\" #{@entitlement_parameter} #{@app_filename}"
		end

		new_ipa_file = "#{@ipa_filename}.resigned.ipa"

		say "Packing resigned ipa file to #{new_ipa_file}" unless options.quiet

		# to zip correctly, it must go to the correct path
		script_folder = Shellwords.escape(Dir.pwd)
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
