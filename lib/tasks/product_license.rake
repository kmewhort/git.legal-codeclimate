namespace :product_license do
  desc "Generate a product license key for a new Pro customer"
  task :generate_key, [:customer_name, :customer_email, :expiry_date] => [:environment] do |task, args|
    raise "Customer name not supplied" if args[:customer_name].blank?
    raise "Customer email not supplied" if args[:customer_email].blank?
    raise "Expiry date (YYYY-MM-DD) not supplied" if args[:expiry_date].blank?

    private_license_dir =  Rails.root.join('..', 'git.legal_ops', 'product_licenses')
    private_key_path = private_license_dir.join('product-private-key')
    raise "Private product key not found at #{private_key_path}" unless File.exist? private_key_path

    # Build a new license.
    private_key = OpenSSL::PKey::RSA.new File.read(private_key_path)
    Gitlab::License.encryption_key = private_key
    license = Gitlab::License.new

    license.licensee = {
      "Name"    => args[:customer_name],
      "Email" => args[:customer_email]
    }
    license.issued_at         = Time.now.to_date
    license.expires_at        = Date.parse(args[:expiry_date])

    # The date admins will be notified about the license's pending expiration.
    # Not required.
    #license.notify_admins_at  = Date.new(2016, 4, 19)

    # The date regular users will be notified about the license's pending expiration.
    # Not required.
    #license.notify_users_at   = Date.new(2016, 4, 23)

    # The date "changes" like code pushes, issue or merge request creation
    # or modification and project creation will be blocked.
    # Not required.
    #license.block_changes_at  = Date.new(2016, 5, 7)

    # Restrictions bundled with this license.
    # Not required, to allow unlimited-user licenses for things like educational organizations.
    #license.restrictions  = {
      # The maximum allowed number of active users.
      # Not required.
    #  active_user_count: 10000
    #}

    puts "License:"
    puts license.to_json

    # Export the license, which encrypts and encodes it.
    data = license.export

    puts "Exported license:"
    puts data

    # Write the license to a file to send to a customer
    license_path = private_license_dir.join(".git-legal_#{args[:customer_email]}_#{args[:expiry_date]}.license")
    File.open(license_path, "w") { |f| f.write(data) }
  end
end
