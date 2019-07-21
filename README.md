# Cloudcheck

Cloudcheck is made to be used in the same folder as [CloudFail](https://github.com/m0rtem/CloudFail "CloudFail"). Make sure all files in this repo are in the same folder before using.

Also create a empty text file called none.txt in the data folder, that way it doesn't do a subdomain brute when testing.

Cloudcheck will automatically change your hosts file, using entries from CloudFail and test for a specified string to detect if said entry can be used to bypass Cloudflare.

If output comes out to be "True", you can use the IP address to bypass Cloudflare in your hosts file. (Later automating this process)

Example: 
![](https://raw.githubusercontent.com/ANK1036Official/Cloudcheck/master/cloudcheck.png)
