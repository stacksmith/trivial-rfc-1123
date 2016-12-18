### TRIVIAL-RFC-1123

Parses and prints dates in [RFC-1123 compatible](https://tools.ietf.org/html/rfc1123) format.  Like this:
```
CL-USER> (ql:quickload :trivial-rfc-1123)
CL-USER> (t1123:parse-date "Fri, 16 Jul 2010 02:33:50 -0500") ;note 't1132:' abbrev.
3488254430
CL-USER> (t1123:as-rfc-1123 3488254430); default tz is 0, or GMT
"Fri, 16-Jul-2010 07:33:50 GMT"

CL-USER> (t1123:as-rfc-1123 3488254430 :timezone 5); 'cause lisp TZ is backwards
"Fri, 16-Jul-2010 02:33:50 -0500"

CL-USER> (t1123:as-rfc-1123 (get-universal-time) :timezone nil); use current tz!
...


```
## (parse-date string)

# Return: universal time for the string.

date-parse-error condition will be raised in case of problems.

## (as-rfc-1123 universal-time &key (stream nil) (timezone 0)

# Stream:
- nil return string
- t output to *standard-output*
- valid stream - output to stream.

# Timezone:
- Specify timezone for output.  Only rational timezones are supported.  Nil means use current tz from (decode-universal-time) which is useful for current time.

# Return: string if stream is nil, nil otherwise.

## History

The code started out in drakma and was shoehorned to be a standalone library for applications requiring minimal date parsing and printing.

According to Drakma authors, the following formats will be parsed:

```
    Wed, 06-Feb-2008 21:01:38 GMT
    Wed, 06-Feb-08 21:01:38 GMT
    Tue Feb 13 08:00:00 2007 GMT
    Wednesday, 07-February-2027 08:55:23 GMT
    Wed, 07-02-2017 10:34:45 GMT
```
The following was added to the drakma code, based on empirical studies of NNTP dates:
```
    07-02-2017 10:34:45 +0800      numeric timezone is ok
    07-02-2017 10:34:45 GMT        omitting day is ok
	WEd, 06-Feb-08 21:01:38 GmT    no longer case sensitive
```

A limited output function was added.  For more flexible output (such as better timezone handling), see (local-time)[https://www.common-lisp.net/project/local-time/] - which sadly does not parse RFC-1123, but outputs it
