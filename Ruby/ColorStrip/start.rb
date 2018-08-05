puts "Running!!"

require 'i2c'

$twi = I2C.create("/dev/i2c-1");
$dropped = 0;
$outData = [];
$total = 0;

def send(array)
		$total += 1;
		begin
			#puts "Starting write ..."
			$twi.write(0x10, array.pack("C*"));
			#puts "Ending write!"
		rescue
		$dropped += 1;
		end
end

at_exit {
	puts "Sent a total of: #{$total} (dropped #{$dropped}, #{($dropped/$total * 100).round(2)}%)";
}

def setPixel(pos, color)
		pos %= 16;
		3.times do |i|
			diff = (pos - pos.floor);
			$outData[pos.floor][i] += (1-diff)*color[i];
			$outData[(pos.floor + 1)%16][i] += diff*color[i];
		end
end

loop do
	$outData = [];
	(16).times do $outData << [0, 0, 0]; end

	f = Time.now.to_f() * 2 * Math::PI;

	setPixel(16 - ((Time.now().sec + Time.now().usec()/1000000)*16/60.0), [100 + 50*Math.sin(f), 0, 0]);
	setPixel(16 - (Time.now().min*16/60), [0, 100, 0]);
	setPixel(16 - (Time.now().hour*16/24), [0, 0, 100]);

	send($outData.flatten);
	sleep 0.07;
end
