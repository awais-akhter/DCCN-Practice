#This code is written by FA20-BSE-021, Muhammad Awais Akhter


# Creating Simulator
set ns [new Simulator]
set nf [open o.nam w]
$ns namtrace-all $nf


#generting variables for comparison
set tcpfile [open out0.tr w]
set udpfile [open out1.tr w]



$ns color 1 Red
$ns color 2 Blue

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]


#coloring of Nodes

#starting
$n1 color Yellow
$n3 color Yellow
$n5 color Yellow
$n7 color Yellow

#ending nodes
$n2 color Pink
$n4 color Pink



$ns duplex-link $n1 $n2 50Mb 5ms FQ
$ns duplex-link $n3 $n2 50Mb 5ms FQ
$ns duplex-link $n5 $n2 50Mb 5ms FQ
$ns duplex-link $n5 $n6 50Mb 5ms FQ
$ns duplex-link $n5 $n7 50Mb 5ms FQ
$ns duplex-link $n6 $n4 50Mb 5ms FQ
$ns duplex-link $n6 $n8 50Mb 5ms FQ
$ns duplex-link $n3 $n4 50Mb 5ms FQ
$ns duplex-link $n3 $n8 50Mb 5ms FQ
$ns duplex-link $n8 $n7 50Mb 5ms FQ
$ns duplex-link $n7 $n4 50Mb 5ms FQ

$ns duplex-link-op $n8 $n7 color Orange
$ns duplex-link-op $n7 $n4 color Green
$ns duplex-link-op $n1 $n2 color Purple

#making agents and connecting to relevant nodes
set udp1 [new Agent/UDP]
$ns attach-agent $n5 $udp1

set udp2 [new Agent/UDP]
$ns attach-agent $n7 $udp2

set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1

set tcp2 [new Agent/TCP]
$ns attach-agent $n3 $tcp2

#agents for ending nodes
set sink_1 [new Agent/TCPSink]
$ns attach-agent $n2 $sink_1

set sink_2 [new Agent/TCPSink]
$ns attach-agent $n4 $sink_2

#connecting forwarding and ending agents
$ns connect $tcp1 $sink_1
$ns connect $tcp1 $sink_2

$ns connect $tcp2 $sink_1
$ns connect $tcp2 $sink_2


#making FTP for generating traffic
set ftp1 [new Application/FTP]
set ftp2 [new Application/FTP]

$ftp1 attach-agent $tcp1
$ftp2 attach-agent $tcp2

#making CBR for generating traffic
set cbr1 [new Application/Traffic/CBR]
set cbr2 [new Application/Traffic/CBR]

$cbr1 set packet_size_ 1000
$cbr2 set packet_size_ 1000

$cbr1 attach-agent $udp1
$cbr2 attach-agent $udp2

#coloring the traffic
$tcp1 set fid_ 1
$tcp2 set fid_ 1
$udp1 set fid_ 2
$udp2 set fid_ 2







proc traffic {} {
    global sink_1 sink_2 tcpfile udpfile
    set ns [Simulator instance]
    set time 0.5
    set bwtcp [$sink_1 set bytes_]
    set bwudp [$sink_2 set bytes_]
    set now [$ns now]
    puts $tcpfile "$now [expr $bwtcp/$time*8/1000000]"
    puts $udpfile "$now [expr $bwudp/$time*8/1000000]"
    $sink_1 set bytes_ 0
    $sink_2 set bytes_ 0
    $ns at [expr $now+$time] "traffic"
}
   


# finish procedure
proc finish {} {
    global ns nf tcpfile udpfile
    $ns flush-trace
    close $nf
    close $tcpfile
    close $udpfile
    exec nam o.nam &
    exec xgraph out0.tr out1.tr &
    exit 0
}


$ns at 0.0 "traffic"
$ns at .5 "$ftp1 start"
$ns at 1.0 "$ftp2 start"
$ns at 16.0 "$ftp1 stop"
$ns at 16.5 "$ftp2 stop"
$ns at 20.0 "finish"

$ns run
