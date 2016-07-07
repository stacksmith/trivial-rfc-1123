###TRIVIAL-RFC-1123

Parses dates in RFC-1123 format (dates that look like **Fri, 16 Jul 2010 02:33:50 -0500**


The code is taken directly from drakma and shoehorned to be standalone library for minimal applications requiring date parsing.

According to the authors, the following formats will be parsed

    Wed, 06-Feb-2008 21:01:38 GMT
    Wed, 06-Feb-08 21:01:38 GMT
    Tue Feb 13 08:00:00 2007 GMT
    Wednesday, 07-February-2027 08:55:23 GMT
    Wed, 07-02-2017 10:34:45 GMT

date-parse-error condition will be raised in case of problems.
 
