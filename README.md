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


## Notes
This is the very first gem I ever made. I created it quick and dirty while working on a bigger project, so I hope u find it useful.
Contact me with questions or ideas if you like.

Florian Eck
it-support@friends-systems.de





