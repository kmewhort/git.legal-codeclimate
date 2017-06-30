class Service::LoadProductLicense < ::MicroService
  def call
    @@license ||= license
  end

  private
  def license
    return nil if customer_product_key.nil?

    Gitlab::License.encryption_key = public_product_key
    Gitlab::License.import(customer_product_key)
  end

  def customer_product_key
    @customer_product_key ||= begin
      file = Dir['/code/.git-legal*.license'].first
      return nil if file.nil?

      File.read(file)
    end
  end

  def public_product_key
    path = Rails.root.join('config','product_key.pub')
    OpenSSL::PKey::RSA.new File.read(path)
  end
end
