class Upload < ActiveRecord::Base
  def self.save_process(upload,name)
    ext =  File.extname(upload.original_filename)
    directory = "upload/save_process"
    if File::exists?("#{Rails.root}/#{directory}#{ext}")
      File.delete("#{Rails.root}/#{directory}#{ext}")  
    end      
    @path = File.join(directory, name+ext)
    file = File.open(@path, "wb")
    file.write(upload.read) 
    file.close
    return [name+ext,@path]
  end
end
