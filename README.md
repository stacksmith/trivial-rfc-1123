### TRIVIAL-RFC-1123

Parses dates in RFC-1123 format.  Like this:
```
CL-USER> (ql:quickload :trivial-rfc-1123)
CL-USER> (t1123:parse-date "Fri, 16 Jul 2010 02:33:50 -0500")
3488254430
```
The code is taken directly from drakma and shoehorned to be standalone library for minimal applications requiring date parsing.

According to the authors, the following formats will be parsed:

```
    Wed, 06-Feb-2008 21:01:38 GMT
    Wed, 06-Feb-08 21:01:38 GMT
    Tue Feb 13 08:00:00 2007 GMT
    Wednesday, 07-February-2027 08:55:23 GMT
    Wed, 07-02-2017 10:34:45 GMT
```
The following was added to the drakma code, based on empirical studies of NNTP dates:

 - omitting the day of week should work as of 28 Nov 2016.

date-parse-error condition will be raised in case of problems.
 
 

 - month and timezone parser is now case-insensitive
