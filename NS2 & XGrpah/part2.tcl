#This code is written by FA20-BSE-021, Muhammad Awais Akhter




# Creating Simulator
set ns [new Simulator]
set nf [open o.nam w]
$ns namtrace-all $nf
$ns rtproto DV


#generting variables for comparison
set tcpfile [open out0.tr w]
set udpfile [open out1.tr w]



$ns color 1 Red
$ns color 2 Blue
$ns color 3 Green
$ns color 4 Orange

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

#shaping the senders
$n1 shape box
$n3 shape box
$n5 shape box
$n7 shape box


$ns duplex-link $n1 $n2 30Mb 10ms FQ
$ns duplex-link $n1 $n3 30Mb 10ms DropTail
$ns duplex-link $n1 $n4 30Mb 10ms DropTail
$ns duplex-link $n1 $n5 30Mb 10ms FQ
$ns duplex-link $n1 $n6 30Mb 10ms FQ
$ns duplex-link $n1 $n7 30Mb 10ms FQ
$ns duplex-link $n1 $n8 30Mb 10ms FQ

$ns duplex-link $n2 $n3 30Mb 10ms DropTail
$ns duplex-link $n2 $n4 30Mb 10ms DropTail
$ns duplex-link $n2 $n5 30Mb 10ms DropTail
$ns duplex-link $n2 $n6 30Mb 10ms DropTail
$ns duplex-link $n2 $n7 30Mb 10ms DropTail
$ns duplex-link $n2 $n8 30Mb 10ms DropTail

$ns duplex-link $n3 $n4 30Mb 10ms FQ
$ns duplex-link $n3 $n5 30Mb 10ms FQ
$ns duplex-link $n3 $n6 30Mb 10ms DropTail
$ns duplex-link $n3 $n7 30Mb 10ms FQ
$ns duplex-link $n3 $n8 30Mb 10ms FQ

$ns duplex-link $n4 $n5 30Mb 10ms DropTail
$ns duplex-link $n4 $n6 30Mb 10ms DropTail
$ns duplex-link $n4 $n7 30Mb 10ms DropTail
$ns duplex-link $n4 $n8 30Mb 10ms DropTail

$ns duplex-link $n5 $n6 30Mb 10ms FQ
$ns duplex-link $n5 $n7 30Mb 10ms FQ
$ns duplex-link $n5 $n8 30Mb 10ms FQ

$ns duplex-link $n6 $n7 30Mb 10ms FQ
$ns duplex-link $n6 $n8 30Mb 10ms FQ

$ns duplex-link $n7 $n8 30Mb 10ms DropTail

#making agents and connecting to relevant nodes
set tcp1 [new Agent/TCP/Reno]
$ns attach-agent $n1 $tcp1

set tcp2 [new Agent/TCP/Reno]
$ns attach-agent $n3 $tcp2

set tcp3 [new Agent/TCP/Reno]
$ns attach-agent $n5 $tcp3

set tcp4 [new Agent/TCP/Reno]
$ns attach-agent $n7 $tcp4

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

$ns connect $tcp3 $sink_1
$ns connect $tcp3 $sink_2

$ns connect $tcp4 $sink_1
$ns connect $tcp4 $sink_2


#making FTP for generating traffic
set ftp1 [new Application/FTP]
set ftp2 [new Application/FTP]
set ftp3 [new Application/FTP]
set ftp4 [new Application/FTP]

$ftp1 attach-agent $tcp1
$ftp2 attach-agent $tcp2
$ftp3 attach-agent $tcp3
$ftp4 attach-agent $tcp4



#coloring the traffic
$tcp1 set fid_ 1
$tcp2 set fid_ 2
$tcp3 set fid_ 3
$tcp4 set fid_ 4







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

$ns rtmodel-at 4.0 down $n7 $n4
$ns rtmodel-at 5.0 up $n7 $n4

$ns at 0.0 "traffic"
$ns at .5 "$ftp1 start"
$ns at 1.0 "$ftp2 start"
$ns at 1.5 "$ftp3 start"
$ns at 2.0 "$ftp4 start"
$ns at 15.0 "$ftp1 stop"
$ns at 15.5 "$ftp2 stop"
$ns at 16.0 "$ftp3 stop"
$ns at 16.5 "$ftp4 stop"
$ns at 20.0 "finish"

$ns run
