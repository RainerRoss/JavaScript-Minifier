//--------------------------------------------------------------------------//
// Address Object															//
//--------------------------------------------------------------------------//

function Address() {
	this.address = new Object();
}

Address.prototype = {
	set: function(firstname, lastname, country, zip, city) {
		this.address.firstname	= firstname;
		this.address.lastname	= lastname;
		this.address.country	= country;
		this.address.zip		= zip;
		this.address.city		= city;
	},
	get: function() {
		return this.address;
	},
	print: function() {
		console.log('Address: ' + JSON.stringify(this.address, 0, 1));
	}
};

//------------------------------------------------------------------------------//
// Usage 																		//
//------------------------------------------------------------------------------//

var MyAddress = new Address();
	
MyAddress.set("Rainer", "Ross", "DE", "86916", "Kaufering");
MyAddress.print();
