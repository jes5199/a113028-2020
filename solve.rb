require "prime"

# A113028, from The On-Line Encyclopedia of Integer Sequences
#
# a(n) is the largest integer whose base n digits are all different that is divisible by each of its individual digits
#
# https://oeis.org/A113028

# Another way to say this is:
# A number is a candidate for this sequence if, in the given base, all its digits are unique, no digit is zero,
# and it is a multiple of the Least Common Multiple of the set of digit; that is: `number % LCM(digits) == 0`

# The first subproblem is to find sets of digits for the given base that are capable of being arranged into a candidate number at all!
#
# There are two rules that can be used to entirely disqualify a set of digits.
#
# The first is "the Ten Rule". In a given base, if a number is a multiple of 10, it will end in a zero, but
# our problem statement precludes zero from appearing in the answer.
# So, in the case of base ten, any LCM(digits) will be a multiple of 10 if the digits include a 5 and any even number.
# This is because the prime factorization of 10 is 2 and 5 - so they cannot *both* appear in the prime factorization
# of our LCM, or else our LCM will itself be a multiple of 10, and then every multiple of the LCM will contain a zero.
#
# So for base ten, an answer will certainly either not include the digit 5, or not include any even digits.
# Similarly, for base 14, an answer will either not include the digit 7, or not include any even digits.
# For base 15, an answer will either not include the digit 5 or A (2*5), or not include any multiples of 3.
#
# For base 8, no digits are disqualified by this rule - because 8 is a prime power, no LCM of numbers less than 8
# will be a multiple of 8. This is true for all prime bases, and all prime power bases.
#
# For base 12, either there must either be no digits that are multiple of *four* or no digits that are a multiple of 3.
# Otherwise, even digits are allowed - 12's prime factorization is 2^2 and 3, but this rule only applies when the prime power
# in a factorizatoin is maxed out. That is to say x*LCM(2,3) does not necessarily contain a zero, but x*LCM(4,3) does.
#
# The other rule is "the Nine Rule"
# You may have learned the base ten version of this in elemetary school, or if you are like me, you learned it from an
# educational music video on public television and will have this song stuck in your head for the rest of the day:
# https://www.youtube.com/watch?v=Q53GmMCqmAM
#
# In base 10, if a number is a multiple of 9, then its digits will sum to a multiple of nine.
# This generalizes to other bases such that if a number is multiple of base-minus-one, its digits will sum to a multiple of base-minus-one.
# The consequence of this for our candidates is, if a set of digits contains base-minus-one, the rest of the digits must also sum to a multiple
# of base-minus-one.
#
# In theory, there are many subsets of digits that satisfy both of these rules for a given base. In practice, though, for all bases after
# base 6, the set with the largest candidate - the actual answer to our problem - will contain a "nine", and have no more than one digit removed
# by each of the Nine rule and the Ten rule.
#
# So, for base 10. Available digits are: [9 8 7 6 5 4 3 2 1], but by the Ten Rule, we should either remove [5] or [8 6 4 2]. We'll remove the 5.
# The remaining digits [9 8 7 6 4 3 2 1] contain base-minus-one and are subject to the Nine Rule. 8+7+6+4+3+2+1 = 31. 31 % 9 = 4, so we need to either
# remove the digit 4 or any set of digits whose sum modulo 9 is 4. Let's just remove the 4.
#
# The LCM of [9 8 7 6 3 2 1] is 504, so our answer must be a multiple of 504


def print_number(n, base)
  print n, " "
  if base <= 36
    p n.to_s(base)
  else
    r = []
    begin
      r.unshift(n%base)
      n /= base
    end while n > 0
    p r
  end
end

base = (ARGV[0] || 10).to_i
debug = ARGV[1]
puts "base #{base}" if debug

base_factors = Prime.prime_division(base).map{|a,b| a**b}.sort

digits = (1...base).to_a.reverse

# Ten Rule
delete_for_ten_rule = digits.find_all do |d|
  d % base_factors.last == 0
end
if delete_for_ten_rule.length > 0
  puts "removing #{delete_for_ten_rule.join(",")} for the Ten Rule" if debug
  digits -= delete_for_ten_rule
end

if base == 6
  puts "removing 5 for the weird exception in base 6" if debug
  digits.delete 5
end

# Nine Rule
if digits[0] == base - 1
  nine_remainder = digits.sum % (base-1)
  delete_for_nine_rule = digits.find do |d|
    d == nine_remainder
  end
  if delete_for_nine_rule
    puts "removing #{delete_for_nine_rule} for the Nine Rule" if debug
    digits.delete delete_for_nine_rule
  end
end

lcm = digits.inject(&:lcm)
puts "lcm is #{lcm}" if debug

n = digits.reduce do |a,b|
  a * base + b
end
print_number(n, base) if debug

count = 0
while n > 0
  count+=1
  rem = n % lcm
  n -= rem # a multiple of the lcm
  print_number(n, base) if debug

  # check each digit to find the largest one that's not in our set
  digits_available = digits.dup
  (digits.length - 1).downto(0) do |place|
    digit = (n / (base ** place)) % base
    if digits_available.delete(digit)
      next
    else
      # decrement this digit and fill the lower ones with (base-1)s
      n -= n % (base ** place) + 1
      break
    end
  end
  if digits_available.length == 0
    puts "base #{base} done in #{count} iterations!" if debug
    print "#{base}: "
    print_number(n, base)
    break
  end
end

if n < 0
  puts "failed for base #{base}"
end
