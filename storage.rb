class Storage

  def initialize(dir)
    @root = dir
    if File.exist?(dir) 
      if File.directory?(dir)
        return
      else
        raise "Data store: #{dir} is not a directory"
      end
    end
    Dir.mkdir(dir) rescue "Data store: Could not create missing #{dir}"
  end

  def read(oid)   # object id
    fn = oid2fname(oid)
    YAML.load(File.read(fn))
  end

  def load_all
    files = Dir.entries(@root).grep(/yaml/).sort
    array = Array.new(files.size,nil)
    files.each {|fn| array[fn.to_i] = YAML.load(File.read(@root+"/"+fn)) }
    array
  end

  def save(object)
    if object.oid.nil?   # we've never saved it before
      nid = next_oid
      object.instance_eval { @oid = nid }
    end
    File.open(oid2fname(object.oid),"w") {|f| f.puts object.to_yaml }
    object.oid
  end

  def delete(oid)
    File.delete(oid2fname(oid)) rescue nil
  end

  private 

  def next_oid
    next_id_fn = "#@root/nextid.txt"
    File.open(next_id_fn,"w") {|f| f.puts "0" } unless File.exist?(next_id_fn)
    @next_oid = File.read("#@root/nextid.txt").to_i 
    File.open(next_id_fn,"w") {|f| f.puts @next_oid + 1 }
    @next_oid
  end
  
  def oid2fname(oid)
    "#@root/%04d.yaml" % oid
  end
end

