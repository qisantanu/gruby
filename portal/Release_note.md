# Release Note
##  Security patches
### What trigger us to do the security patches for the Managememnt Portal?

We use Dependabot tool for our projects. Dependabot scans your project's dependencies for known security vulnerabilities. It helps you identify and address potential security issues with timely alerts when security updates are available for your dependencies, allowing you to stay ahead of potential threats.
In this process, the library versions updated are:

| Component | Library name | Old Version | New Version | Description |
| ---------------------|-------------|---------------|---------|-----------|
| MP | Puma | 6.2 | 6.3.1 | Prior to version 6.3.1, puma exhibited incorrect behavior when parsing chunked transfer encoding bodies and zero-length Content-Length headers in a way that allowed HTTP request smuggling |
| MP | Rails, ActiveRecord | 6.1.4 | 6.1.7.6 | SQL Injection Vulnerability via ActiveRecord comments |
| MP | minimist | 1.1.3 | 1.2.6 | Previous versions had a prototype pollution bug that could cause privilege escalation in some circumstances when handling untrusted user input |
| MP | loader-utils | 1.0.1 | 2.0.4 | Prototype pollution in webpack loader-utils |
| MP | json-schema | 0.2.3 | 0.4.0 | Before this version was vulnerable to Prototype pollution |
| MP | Node JS | 14.x | 16.x | https://github.com/nodejs/node/blob/main/doc/changelogs/CHANGELOG_V16.md#16.20.2 |
| XSDK API | Puma | 5.6 | 6.4.0 | Prior to version 6.3 , puma exhibited incorrect behavior when parsing chunked transfer encoding bodies and zero-length Content-Length headers in a way that allowed HTTP request smuggling |
| XSDK API | Rails | 7.0.5  | 7.0.8 | New version of the Rails includes bug fixes, often include security fixes discovered in previous version |


## Improvement/Request

  LTA requested to migrate the existing DataMall developers who have completed the registration before EXTOL go live(2nd May 2023) to EXTOL
  
### Enhancement Required:
To migrate the existing DataMall develoepersto EXTOL and trigger welcome email to the developers who opt for mailing list.