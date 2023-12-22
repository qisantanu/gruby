class ObuDetail 
  

  def self.generate_sample_file(n = 100)
    File.delete('samples/test.txt') if File.exist?('samples/test.txt')
    current_time = Time.now
    progress_bar = ProgressBar.new(n, :bar, :rate, :eta)
    record_type = 'D'
    filler = ' '
    creation_data = current_time.strftime('%Y%m%d%H%M')
    header = "H#{creation_data}#{filler * 210}"

    File.open('samples/test.txt', 'a') do |line|
      line.puts header

      n.times do |i|
        vehicle_number = Faker::Vehicle.vin.first(8) + filler * 4
        detail_record_v = record_type + vehicle_number

        obu_label = Faker::Number.number(digits: 10).to_s
        obu_external_public_key = Faker::Alphanumeric.alphanumeric(number: 182).upcase
        vehicle_registered_date = current_time.strftime('%Y%m%d%H%M%S') + Faker::Number.number(digits: 3).to_s

        detail_record = detail_record_v + obu_label +
                        obu_external_public_key + vehicle_registered_date + filler

        line.puts detail_record
        progress_bar.increment!
      end

      line.puts "T#{n}#{filler * 215}"
    end
  end
end
