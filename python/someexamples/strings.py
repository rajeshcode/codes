#!/usr/bin/python -tt

import sys

def repeat(s, exclaim):
    """
    Returns the string 's' repeated 3 times.
    If exclaim is true, add exclamation marks.
    """

    result = s + s + s # can also use "s * 3" which is faster (Why?)
    if exclaim:
        result = result + '!!!'
    return result

    """
     Python's "repeat" operator, meaning that '-' * 10 gives '----------',
     a neat way to create an onscreen "line." In the code comment, we hinted that * works faster than +,
     the reason being that * calculates the size of the resulting object once whereas with +,
     that calculation is made each time + is called. Both + and * are called "overloaded" operators because they mean
     different things for numbers vs. for strings (and other data types).

    """


# Provided simple test() function used in main() to print
# what each function returns vs. what it's supposed to return.
def test(got, expected):
  if got == expected:
    prefix = ' OK '
  else:
    prefix = '  X '
  print '%s got: %s expected: %s' % (prefix, repr(got), repr(expected))


# B. both_ends
# Given a string s, return a string made of the first 2
# and the last 2 chars of the original string,
# so 'spring' yields 'spng'. However, if the string length
# is less than 2, return instead the empty string.
def both_ends(s):
  # +++your code here+++
  # LAB(begin solution)
  if len(s) < 2:
    return ''
  first2 = s[0:2]
  last2 = s[-2:]
  return first2 + last2

# C. fix_start
# Given a string s, return a string
# where all occurences of its first char have
# been changed to '*', except do not change
# the first char itself.
# e.g. 'babble' yields 'ba**le'
# Assume that the string is length 1 or more.
# Hint: s.replace(stra, strb) returns a version of string s
# where all instances of stra have been replaced by strb.
def fix_start(s):
  # +++your code here+++
  # LAB(begin solution)
  front = s[0]
  back = s[1:]
  fixed_back = back.replace(front, '*')
  return front + fixed_back

# D. MixUp
# Given strings a and b, return a single string with a and b separated
# by a space '<a> <b>', except swap the first 2 chars of each string.
# e.g.
#   'mix', pod' -> 'pox mid'
#   'dog', 'dinner' -> 'dig donner'
# Assume a and b are length 2 or more.
def mix_up(a, b):
  # +++your code here+++
  # LAB(begin solution)
  a_swapped = b[:2] + a[2:]
  b_swapped = a[:2] + b[2:]
  return a_swapped + ' ' + b_swapped
  
def Hello(name):
  name = name + '!!!!'
  print 'Hello', name
  if name == 'Guido':
        print repeeeet(name) + '!!!'
  else:
        print repeat(name, False)


def main():
  print 'Strings'
  print 'Hi %s well done %d' %  ( "raj", 25)
  print repeat('Yay', False)      ## YayYayYay
  print repeat('Woo Hoo', True)   ## Woo HooWoo HooWoo Hoo!!!
  Hello(sys.argv[1])

  print
  print 'both_ends'
  test(both_ends('spring'), 'spng')
  test(both_ends('Hello'), 'Helo')
  test(both_ends('a'), '')
  test(both_ends('xyz'), 'xyyz')

  print
  print 'fix_start'
  test(fix_start('babble'), 'ba**le')
  test(fix_start('aardvark'), 'a*rdv*rk')
  test(fix_start('google'), 'goo*le')
  test(fix_start('donut'), 'donut')

  print
  print 'mix_up'
  test(mix_up('mix', 'pod'), 'pox mid')
  test(mix_up('dog', 'dinner'), 'dig donner')
  test(mix_up('gnash', 'sport'), 'spash gnort')
  test(mix_up('pezzy', 'firm'), 'fizzy perm')
 

#Standard boilerplate to call the main() funtion.
if __name__ == '__main__':
  main()
