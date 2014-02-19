[![Build Status](https://travis-ci.org/florianeck/smart_search.png?branch=master)](https://travis-ci.org/florianeck/smart_search)

# SmartSearch
A simple search plug-in which provides a full-text search for ActiveRecord Models. 
It builds the search tags based upon the attributes you define in your model.

It requires a MySQL Database, and the mysql2 gem!

## How to use
First run 

    rake smart_search:install:migrations


### Setting up your data 
To get the data which will be used for your index there are two ways:
    
    # Attributes can be symbols:
    # Use symbols to access your models instance methods and attributes
    smart_search :on => [:first_name, :last_name]
    
    # Attributes can be strings:
    # Use this to access nested attributes
    smart_search :on => ["customer.first_name", "cutomer.last_name"]

You can define the attributes for the index in your model in two different ways.
With and without evalutation:

    # Without evaluation
    # All attributes have the save importance 
    smart_search :on => ["customer.first_name", "cutomer.last_name"]
    
    # With evaluation
    # Higher Boost == higher importance
    smart_search :on => [
      {:field_name => "customer.first_name", :boost => 2.5}, 
      {:field_name => "cutomer.last_name", :boost => 1}
    ]
    
    # So a customer with matching first_name will be higher ranked 
    # then one with matching last name
    
#### Filling the index
   
smart_searched models will automatically update their search tags after save.
To set search tags for all rows in database, use 

    Model.set_search_index   

Find entries by using:

    Model.find_by_tags("your search tags")
    
### Adding default conditions
To add default conditions:

    smart_search :on => [- define attributes here-], :conditions => "- SQL Conditions here -"

Will only find matching tags and the given condition    


### Example:   
Lets say you have a Customer model which has the columns 'first_name', 'last_name' and 'email' and also belongs to a User, who also has the column 'name'.

To build your search for Customer, add:
   
    smart_search :on => [:first_name, :last_name, :email, 'user.name']

to your model. For accessing columns of the model, use symbols, for accessing
methods use strings.

#### See example code below:

    class User < ActiveRecord::Base
  
      belongs_to :office, :class_name => "Office", :foreign_key => "office_id"
  
      smart_search :on => [:full_name, 'office.name']
  
      def full_name
        "#{self.first_name} #{self.last_name}"
      end  
    end

Saving an User with first_name = "Test" and last_name = "User" the created search tags would be "test user".
User.find_by_tags("Test User") would find the User.
If the User belongs to an office with name "Headquarter", the search tags would be "test user headquarter".
User.find_by_tags("Test Headquarter") would find the User.

    User.find_by_tags("Test", :conditions => {:office_id => 1}) 

Also works as expected:-)    

#### Some other examples 
    class Customer < ActiveRecord::Base
      smart_search :on => [:first_name, :last_name, 'user.full_name', 'user.office.name', :birthday], :conditions => "is_private = 0"
  
      def user
        User.find(self.user_id)
      end  
  
    end        

    class Office < ActiveRecord::Base
      smart_search :on => [:name, :user_names]
  
      def user_names
        self.users.map {|u| u.full_name }.join(" ")
      end
  
      def users
        User.find_all_by_office_id(self.id)
      end    
    end  



## New Similarity Feature!
This is still very experimental.
THis gem now allows to build up a table with word similarities and combine your search query with other words you might be looking for.

See class 'SmartSimilarty' for more infos...

Documentation coming soon

Added rake tasks for loading similarity data

    rake smart_search:similarity_from_file           # Load similarity data from file - Use FILE=path/to/file to specify file
    rake smart_search:similarity_from_query_history  # Load similarity data from query history
    rake smart_search:similarity_from_url            # Load similarity data from url - Use URL=http://.../ to specify url - Requires 'curl'

These will fill the similarity table with word similarity data.


## RDoc Status

    Files:       7

    Classes:     6 (2 undocumented)
    Modules:     3 (0 undocumented)
    Constants:   5 (0 undocumented)
    Attributes:  0 (0 undocumented)
    Methods:    19 (3 undocumented)

    Total:      33 (5 undocumented)
     84.85% documented

## TODO
- Maybe add a search controller, and some views for quick starting...
- Documentation for similarities
- make configurable with initializer
- Dont split searchable attributes if no boost is used
  - combine attributes with same boost (increases performance)


Florian Eck
it-support@friends-systems.de


## License
The MIT License (MIT)

Copyright (c) [2014] [Florian Eck]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

