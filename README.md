# Hello, folks! <img src="https://raw.githubusercontent.com/MartinHeinz/MartinHeinz/master/wave.gif" width="30px">

My name is Okan and I'm a student of Computer Engineer. You can find me on [![LinkedIn][1.2]][1].

# System includes:
- Login, Dashboard, Logout

- View User Profile, Warehouses, Staff

- View Orders, Shipments, Packages, Products

- Track packages, Control bills

- 3 user types that are Admin, Staff and basic user

- Add/Edit/Delete operations within your jurisdiction

## 🔧 Technologies & Tools
![](https://img.shields.io/badge/OS-Windows-Green?style=flat&logo=linux&logoColor=white&color=2bbc8a)
![](https://img.shields.io/badge/Editor-VisualStudio-information?style=flat&logo=html5%20ide&logoColor=white&color=2bbc8a)
![](https://img.shields.io/badge/Code-Csharp-informational?style=flat&logo=c-sharp&logoColor=white&color=2bbc8a)
![](https://img.shields.io/badge/Code-HTML-informational?style=flat&logo=html5&logoColor=white&color=2bbc8a)
![](https://img.shields.io/badge/Code-CSS-informational?style=flat&logo=css3&logoColor=white&color=2bbc8a)
![](https://img.shields.io/badge/Tools-MSSQL-informational?style=flat&logo=sql&logoColor=white&color=2bbc8a)

# Screenshots
Login page
![1](https://user-images.githubusercontent.com/67058617/105500050-6490d400-5cd3-11eb-9587-593a013f4f76.PNG)
Admin main page
![admin](https://user-images.githubusercontent.com/67058617/105500067-6a86b500-5cd3-11eb-8602-4a68cba6b0ad.PNG)
Staff main page
![staff](https://user-images.githubusercontent.com/67058617/105500069-6b1f4b80-5cd3-11eb-8d5b-d5cc83b80bf4.PNG)
User main page
![user](https://user-images.githubusercontent.com/67058617/105500065-69ee1e80-5cd3-11eb-9888-bd139fb1588e.PNG)
User list
![Ekran Alıntısı](https://user-images.githubusercontent.com/67058617/105500086-6fe3ff80-5cd3-11eb-9be0-44a7ac6f9866.PNG)
User profile
![3](https://user-images.githubusercontent.com/67058617/105500089-707c9600-5cd3-11eb-9fe9-e342645c64fd.PNG)
Packages list
![package](https://user-images.githubusercontent.com/67058617/105500090-71152c80-5cd3-11eb-8abd-7204b6282593.PNG)
Package Detail
![detail](https://user-images.githubusercontent.com/67058617/105500082-6eb2d280-5cd3-11eb-803e-59c6fdeda884.PNG)
Edit Product Quantity
![edit](https://user-images.githubusercontent.com/67058617/105500085-6fe3ff80-5cd3-11eb-8710-d2fc251f7376.PNG)
Track a package and include all informations
![2](https://user-images.githubusercontent.com/67058617/105500087-707c9600-5cd3-11eb-9d6d-aa1add4e66d4.PNG)

# What does this projects do?
The Online Warehousing Information System (OWIS), information about the warehousing environment including operations of the warehousing company with the incoming and outgoing packages, warehouses, suppliers, products and user information are stored. This system have 3 user types such as Admin, Staff and Basic user. 
Admin which has all permisions, is mainly responsible of maintaining the users, suppliers, warehouses, staff and products. Admin can any CRUD actions over any specific record. Admin users are the owners or the managers of the system. 
Users which have the user type '1' are the staff members. Staff members are responsible for the transactions on their specific warehouse. They can perform CRUD operations for incoming or outgoing transactions, but they are not authorized for any operation on any object else even including their own user account which is in responsibility of the admin users. The last user type, basic users, can only view the status of products, warehouses and transactions. 
Basic users can also track packages like other user types. In short, admin users are the responsible ones for the OWIS, staff members are the responsible ones for the warehouses with transactions and the basic users are only authorized for the monitoring operations. 

System keeps track of the incoming or outgoing products with the products table where products’ information (name, description, image, manufacturer, weight) and current quantity is held. System also has the inventory table which is including only products those are in stock with their quantity. The source of products, suppliers, are also recorded in a table with their brand information (name, country, city) and contact information (address, phone number, e-mail). Whenever needed, product, inventory or the supplier information can be gathered via these tables.

Transactions between warehouses (incoming or outgoing) are made by orders(incoming) and shipments(outgoing). Each order or shipment has its own package, and every package has its own content that is kept within the package contents table with product’s quantities. These packages have related order or shipment ID, a bit value for package’s direction (0 for incoming and 1 for outgoing), supplier ID, created time information, package status (to inform user) and additional notes. Every transaction can have more than one package, but every package is belonging to only one transaction. 

To keep the records of the payment operations, each order has a payment, and each shipment has a bill record. Payments keeps the record of money paid for orders and bills are the records of money paid to the company by shipments

For every package, there is the shipping record within the shipping table that is keeping the package’s ID, current location, status, shipping date, estimated delivery date (if exists), delivery date(if delivered) and shipping note if given. Package track requests will be satisfied by this table’s records. 


## &#x1f4c8; GitHub Stats
[![Top Langs](https://github-readme-stats.vercel.app/api/top-langs/?username=vasseurr)](https://github.com/anuraghazra/github-readme-stats)

![Okan's GitHub stats](https://github-readme-stats.vercel.app/api?username=Vasseurr&show_icons=true&theme=dracula)

[![Readme Card](https://github-readme-stats.vercel.app/api/pin/?username=Vasseurr&repo=User-Authentication)](https://github.com/Vasseurr/User-Authentication)

[![Readme Card](https://github-readme-stats.vercel.app/api/pin/?username=Vasseurr&repo=MatchCard)](https://github.com/Vasseurr/MatchCard)



<!-- links to social media icons -->

[1.1]: http://i.imgur.com/0o48UoR.png (github icon with padding)
[1.2]: https://img.icons8.com/plasticine/25/000000/linkedin.png (LinkedIn icon without padding)

<!-- links to your social media accounts -->

[1]: https://www.linkedin.com/in/okanruzgar/
[2]: https://github.com/Vasseurr

