package Statistics::CountAverage;
use 5.008008;
use strict;
use warnings;


our $VERSION = '0.01';
use Time::HiRes qw(gettimeofday);

sub new {
    my $class = shift;
	my %args = @_;
    my $self = bless \%args, $class;
	$self->{len} ||= 10;
	$self->{count} = 0;
	$self->{time} = 0;
	$self->{ary} = [{count => 0, time => scalar gettimeofday(),diff => 0}];
    return $self;
}
# $obj->count(100) - подсчитать 100 событий
sub count {
	my $self = shift;
	my $add = shift || 1 ;

	my $now = gettimeofday();
	my $prev = $self->{ary}[-1]{time};
	my $diff = $now - $prev;

	my $tmp = {count => $add, time => $now, diff => $diff};

	push @{$self->{ary}},$tmp;
	$self->{count} += $add;
	$self->{time} += $diff;
	
	if(@{$self->{ary}} > $self->{len}){
		$tmp = shift @{$self->{ary}};
		$self->{count} -= $tmp->{count};
		$self->{time} -= $tmp->{diff};
	}
}
# $obj->check(10) - возвращает true 1 раз каждые 10 секунд
# вернет true если со времени последнего возврата true прошло <= 10 секунд
sub check {
	my $self = shift;
	my $to = shift || 1;
	my $now = gettimeofday();
	if(($self->{last} ||= $now) + $to > $now){
		return 0;
	}
	$self->{last} = $now;
}
# число событий за секунду
sub speed {
	my $self = shift;
	return $self->{count}/($self->{time}||1);
}
# число подсчетов за секунду
sub rate {
	my $self = shift;
	return @{$self->{ary}}/($self->{time}||1);
}
# количество событий за подсчет
sub avg {
	my $self = shift;
	return $self->{count}/@{$self->{ary}};
}
# список количестыва событий в каждом подсчете
sub list_count {
	my $self = shift;
	return map {$_->{count}} @{$self->{ary}};
}
# список временных интервалов между посчетами
sub list_diff {
	my $self = shift;
	return map {$_->{diff}} @{$self->{ary}};
}
sub stat {
	my $self = shift;
	return +{
		speed => $self->{count}/($self->{time}||1),
		rate => @{$self->{ary}}/($self->{time}||1),
		avg => $self->{count}/@{$self->{ary}},
	};
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Statistics::CountAverage - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Statistics::CountAverage;
  
  my $avg = new Statistics::CountAverage(len => 100);
  $avg->count;
  ...
  $avg->count(10);
  ...
  if($avg->check(5)){
    print "speed: ",$avg->speed,"\n";
  }
  print "rate: ",$avg->rate,"\n";
  print "rate: ",$avg->av,"\n";
  
=head1 DESCRIPTION


Blah blah blah.

=head1 FUNCTIONS

=head2 count(number)
  
count number action

  $avg->count(10);

=head2 check(sec)
  
return true  if elapset sec from last true

  $avg->check(5);


=head1 SEE ALSO


=head1 AUTHOR

Ildar Efremov, E<lt>iefremov@2reallife.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Ildar Efremov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
