require 'pdf-reader'
files = Dir["home/pdfs/*"] #Directory where pdf files are located
files.each do |file|
  hash = {}
  reader = PDF::Reader.new(open(file))
  page = reader.pages.first
  lines = page.to_s.split("\n")
  v_line_index = []
  lines.each_with_index do |l , index|
    if  l.strip.start_with?("v.")
      v_line_index.append(index)
    end
  end
  next if lines.empty? or v_line_index.empty?
  data_set = []
  data_set << lines[1..v_line_index[0]-1]
  data_set << lines[v_line_index[0]+1..v_line_index[0]+7]
  data_set.each do |data|
    data = data.map{|e| e.strip.split('  ')[0]}.reject{|e| e.nil? }
    key_index = data.find_index(data.select {|e| e.include? 'Petitioner,' or e.include? 'Petitioners,' or e.include? 'Appellant,' or e.include? 'Appellees.' or e.include? 'Appellee.' or e.include? 'Respondent.'}[0])
    key = data[key_index] rescue byebug
    value = (data[key_index-1].include? 'Date' or data[key_index-1].include? 'DOB') ? data[key_index-2] : data[key_index-1]
    hash[key] = value
  end
  hash["date"] = lines.select {|l| l.include? 'Date of'}[0].split(':')[1].strip
  amount_line = lines.select {|l| l.include? '$'}[0]
  amount_index = amount_line.index('$') rescue nil
  hash["amount"] = '$' + amount_line[amount_index..amount_index+10].tr('^0-9.', '') rescue nil
  puts hash
end
