# SmartSearch
A simple search plug-in which provides a full-text search for ActiveRecord Models. 
It builds the search tags based upon the attributes you define in yout model.

## How to use
To use smart_search, just add the following line to your model:

    smart_search :on => [- define attributes here-]
   
smart_searched models will automatically update their search tags after save.
To set search tags for all rows in database, use Moldel.set_search_index   

Find entries by using:

    Model.find_by_tags("your search tags")
    
### Adding default conditions
To add default conditions:
    smart_search :on => [- define attributes here-], :conditions => "- SQL Conditions here -"

Will only find matching tags and the given condition    

### Adding search tags column
smart_search automatically adds the 'search_tags' column to your model.
This happens when initializing the model.

Make sure to restart the server after adding column, otherwise, ActiveRecord wont recognize it.


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



## Notes
This is the very first gem I ever made. I created it quick and dirty while working on a bigger project, so I hope u find it useful.
Contact me with questions or ideas if you like.

### TODO
Maybe add a search controller, and some views for quick starting...

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

