// class CartItem {
//   final String id; // A unique identifier is good practice
//   final String name;
//   final String image;
//   final double price;
//   final double rating;
//   final String restaurantName;
//   final int quantity;

//   CartItem({
//     required this.id,
//     required this.name,
//     required this.image,
//     required this.price,
//     required this.rating,
//     required this.restaurantName,
//     this.quantity = 1,
//   });

//   // Method to create a new CartItem with updated quantity
//   CartItem copyWith({int? quantity}) {
//     return CartItem(
//       id: this.id,
//       name: this.name,
//       image: this.image,
//       price: this.price,
//       rating: this.rating,
//       restaurantName: this.restaurantName,
//       quantity: quantity ?? this.quantity,
//     );
//   }
// }