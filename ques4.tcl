
set input [gets stdin]
scan $input "%d %d" N k

set ns [new Simulator]

$ns rtproto DV

set nf [open out.nam w]
$ns namtrace-all $nf

proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exec nam out.nam
    exit 0
}

for {set i 0} {$i < $N} {incr i} {
	set node($i) [$ns node]
}

for {set i 0} {$i < $N} {incr i} {
	$ns duplex-link $node($i) $node([expr ($i + 1) % $N]) 512Kb 5ms DropTail
}

set colors(0) Yellow
set colors(1) Green
set colors(2) Orange
set colors(3) Pink
set colors(4) Red
set colors(5) Blue

for {set i 0} {$i < $k} {incr i} {
	set input [gets stdin]
	scan $input "%d %d" u v

	set tcp_con [new Agent/TCP]
	$ns attach-agent $node($u) $tcp_con
	$tcp_con set class_ $i

	set sink_node [new Agent/TCPSink]
	$ns attach-agent $node($v) $sink_node
	$ns connect $tcp_con $sink_node

	$ns color $i $colors([expr ($i) % 6])
	$tcp_con set fid_ $i

	set ftp_con [new Application/FTP]
	$ftp_con attach-agent $tcp_con
	$ns at 0.1 "$ftp_con start"
	$ns at 1.5 "$ftp_con stop"
}

$ns at 2.0 "finish"
$ns run