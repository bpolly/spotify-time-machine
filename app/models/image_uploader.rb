module ImageUploader
  def self.upload_to_s3(image_link:, filename:)
    s3_image_url = "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/#{filename}.png"
    file = Rails.root.join('tmp', "#{filename}.png").to_s
    return s3_image_url if S3_BUCKET.object(File.basename(file)).exists?

    File.open(file, 'wb') do |f|
      f.write HTTParty.get(image_link).body
    end

    S3_BUCKET.object(File.basename(file)).upload_file(file, acl: 'public-read')
    File.delete(file) if File.exist?(file)
    s3_image_url
  end
end
