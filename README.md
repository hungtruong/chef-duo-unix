Description
===========
Installs Duo Unix 2-factor authentication. Currently tested (barely) on Debian 7.0 x32, Ubuntu 12.04 x32 Server, Ubuntu 12.10 x32 Server

Requirements
============

## Platform:

* Debian/Ubuntu

Attributes
==========
See the [Duo Unix documentation](https://www.duosecurity.com/docs/duounix) for details on required attributes, and see `attributes/default.rb` for set defaults.

Minimum requirements for this recipe are:

* `node['duo_unix']['conf']['integration_key']` - Your Duo Unix integration key
* `node['duo_unix']['conf']['secret_key']` - Your Duo Unix integration secret key
* `node['duo_unix']['conf']['api_hostname']` - Your Duo Unix integration api hostname

Usage
=====

Complete the 'first steps' as described in the [Duo Unix documentation](https://www.duosecurity.com/docs/duounix). 

	{    "run_list":[
		"recipe[duo_unix]"
       ],
     "duo_unix": {
     	"conf" :{
     	"integration_key" : "YOUR_INTEGRATION_KEY",
     	"secret_key" : "YOUR_SECRET_KEY",
     	"api_hostname" : "YOUR_API_HOSTNAME"
    	 }
 		}
	 }

TODO
====
* Support PAM configuration.
* More testing.

License and Author
==================

- Author:: Hung Truong (<hung@hung-truong.com>)

Copyright:: 2013 Hung Truong

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.