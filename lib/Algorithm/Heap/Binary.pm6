use v6;
use Algorithm::Heap;

# https://en.wikipedia.org/wiki/Heap_(data_structure)

class Algorithm::Heap::Binary:ver<0.0.1>:auth<cono "q@cono.org.ua"> does Algorithm::Heap {
    has Pair @.data;

    multi method new($comparator = * <=> *) {
        self.bless(:$comparator, data => Array[Pair].new);
    }

    multi method new(:$comparator!) {
        self.bless(:$comparator, data => Array[Pair].new);
    }

    multi method new(:$comparator = * <=> *, *@input) {
        my Pair @data;
        @data.append(@input) if @input.elems;

        self.bless(:$comparator, :@data);
    }

    submethod BUILD(Comparator :$comparator, :@data) {
        $!comparator = $comparator;
        @!data := @data;

        if @!data.elems {
            for (@!data.elems div 2) ... 1 -> $index {
                self.sift-down($index);
            }
        }
    }

    # clone doesn't do @. and %. attributes automatically
    method clone {
        nextwith :data(@!data.clone);
    }

    method is-empty returns Bool {
        return @!data.elems == 0;
    }

    method size returns Int {
        return @!data.elems;
    }

    # bring it back when perl6 will have tail recursion
    #multi method sift-up(1) { };
    #multi method sift-up(Int $n) {
    #    my $cur-index = $n - 1;
    #    my $parent-index = $n div 2 - 1;
    #    my $cur = @!data[$cur-index].key;
    #    my $parent = @!data[$parent-index].key;

    #    if &!comparator($cur, $parent) < Same {
    #        @!data[$cur-index, $parent-index] = @!data[$parent-index, $cur-index];
    #        samewith($parent-index + 1);
    #    }
    #}
    method sift-up(Int $n) {
        my $it = $n;
        while ($it > 1) {
            my $cur-index = $it - 1;
            my $parent-index = $it div 2 - 1;
            my $cur = @!data[$cur-index].key;
            my $parent = @!data[$parent-index].key;

            last if $!comparator($parent, $cur) < Same;

            @!data[$cur-index, $parent-index] = @!data[$parent-index, $cur-index];
            $it = $parent-index + 1;
        }
    }

    method insert(Pair $val) {
        @!data.push($val);
        self.sift-up(@!data.elems);
    }

    # not implemented yet
    # our &push ::= &insert;

    method push(Pair $val) { self.insert($val) }

    # bring it back when perl6 will have tail recursion
    #method sift-down(Int $n) {
    #    my $left-index = $n * 2 - 1;
    #    my $right-index = $n * 2;
    #    my $target-index = $n - 1;

    #    if $left-index < @!data.elems && &!comparator(@!data[$target-index].key, @!data[$left-index].key) > Same {
    #        $target-index = $left-index;
    #    }
    #    if $right-index < @!data.elems && &!comparator(@!data[$target-index].key, @!data[$right-index].key) > Same {
    #        $target-index = $right-index;
    #    }

    #    if $target-index != $n - 1 {
    #        @!data[$n - 1, $target-index] = @!data[$target-index, $n - 1];
    #        self.sift-down($target-index + 1);
    #    }
    #}
    method sift-down(Int $n) {
        my $it = $n;

        while (True) {
            my $left-index = $it * 2 - 1;
            my $right-index = $it * 2;
            my $target-index = $it - 1;

            if $left-index < @!data.elems && $!comparator(@!data[$target-index].key, @!data[$left-index].key) > Same {
                $target-index = $left-index;
            }
            if $right-index < @!data.elems && $!comparator(@!data[$target-index].key, @!data[$right-index].key) > Same {
                $target-index = $right-index;
            }

            last if $target-index == $it - 1;

            @!data[$it - 1, $target-index] = @!data[$target-index, $it - 1];
            $it = $target-index + 1;
        }
    }

    method peek {
        return @!data.first;
    }

    # not implemented yet
    # our &find-max ::= &peek;
    # our &find-min ::= &peek;
    method find-max { self.peek }
    method find-min { self.peek }

    method pop returns Pair {
        return Nil unless @!data.elems;
        return @!data.pop if @!data.elems == 1;

        my $result = @!data.first;
        @!data[0] = @!data.pop;

        self.sift-down(1);

        return $result;
    }

    # not implemented yet
    # our &delete-max ::= &pop;
    # our &delete-min ::= &pop;
    method delete-max returns Pair { self.pop }
    method delete-min returns Pair { self.pop }

    method replace(Pair $val) returns Pair {
        my $result = @!data.first;

        @!data[0] = $val;
        self.sift-down(1);

        return $result;
    }

    method merge(Algorithm::Heap::Binary $heap) {
        my Pair @new;
        @new.append(|@!data, |$heap.data);

        return self.new(:$.comparator, |@new);
    }

    method Seq {
        Seq.new(self.iterator);
    }

    method Str {
        @!data.Str;
    }

    method iterator {
        return class :: does Iterator {
            has Algorithm::Heap::Binary $.heap is required;

            method pull-one {
                return self.heap.pop // IterationEnd;
            }
        }.new(heap => self.clone);
    }
}

# vim: ft=perl6
