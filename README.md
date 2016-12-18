### TRIVIAL-RFC-1123

Parses and prints dates in RFC-1123 format.  Like this:
```
CL-USER> (ql:quickload :trivial-rfc-1123)
CL-USER> (t1123:parse-date "Fri, 16 Jul 2010 02:33:50 -0500")
3488254430
CL-USER> (t1123:as-rfc-1123 3488254430 :timezone 5); 'cause lisp TZ is backwards
"Fri, 16-Jul-2010 02:33:50 -0500"

Beware: not specifying :timezone will use _your current_ Daylight Savigs Time value.
This makes no sense to me, but I am only an egg:

CL-USER> (t1123:as-rfc-1123 3488254430)
"Fri, 16-Jul-2010 00:33:50 -0800" NOTE - only 2 hour difference! I am on DS time.  Wha???

```
date-parse-error condition will be raised in case of problems.


The code started out in drakma and was shoehorned to be standalone library for minimal applications requiring date parsing and printing.

According to the authors, the following formats will be parsed:

```
    Wed, 06-Feb-2008 21:01:38 GMT
    Wed, 06-Feb-08 21:01:38 GMT
    Tue Feb 13 08:00:00 2007 GMT
    Wednesday, 07-February-2027 08:55:23 GMT
    Wed, 07-02-2017 10:34:45 GMT
```
The following was added to the drakma code, based on empirical studies of NNTP dates:

- 28 Nov 2016.  Omitting the day of week should work as of 28 Nov 2016.
- 01 Dec 2016.  Month and timezone parser is now case-insensitive (nntp servers have some like that)
- 17 Dec 2016.  RFC-1123 output as well, by popular demand.
