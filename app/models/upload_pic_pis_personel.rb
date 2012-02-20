class UploadPicPisPersonel < ActiveRecord::Base
  def self.save(upload,name)
    ext =  File.extname(upload.original_filename)
    directory = "public/images/personel"
    if File::exists?("#{Rails.root}/#{directory}#{ext}")
      File.delete("#{Rails.root}/#{directory}#{ext}")  
    end      
    @path = File.join(directory, name+ext)
    File.open(@path, "wb") { |f| f.write(upload.read) }
    return name+ext
  end
end
