// Centralized Product Database
const dbProducts = [
    { id: 1, name: "Cashmere Ribbed Cardigan", category: "Cardigan", material: "Cashmere", price: 1500000, img: "https://i.pinimg.com/1200x/8d/08/28/8d0828d51cfc26c57e0cb10974ebb04c.jpg" },
    { id: 2, name: "Coach Ribbon Shoulder Bag", category: "Bags", material: "Leather", price: 51200000, img: "https://i.pinimg.com/736x/76/a0/ff/76a0ffa9055eff73cafdec1f87478b40.jpg" },
    { id: 3, name: "Milan Leather Jordan Shoes", category: "Shoes", material: "Leather", price: 53900000, img: "https://i.pinimg.com/736x/9c/b9/10/9cb910dc405be286b9b09f1de23056e4.jpg" },
    { id: 4, name: "Denim Long Trousers", category: "Pants", material: "Denim", price: 950000, img: "https://images.unsplash.com/photo-1718252540511-e958742e4165?w=500&auto=format&fit=crop&q=60" },
    { id: 5, name: "Leather Backpack", category: "Bags", material: "Leather", price: 22000000, img: "https://i.pinimg.com/736x/52/f2/b0/52f2b090b2b3245e201b84bae187d2a6.jpg" },
    { id: 6, name: "Chelsea Ankle Boots", category: "Shoes", material: "Leather", price: 22800000, img: "https://i.pinimg.com/736x/a3/8f/b5/a38fb5b1fe8ec8432fc978e7dfedb150.jpg" },
    { id: 7, name: "Chelsea Shirt Denim", category: "Shirt", material: "Denim", price: 2800000, img: "https://i.pinimg.com/1200x/2d/ee/9d/2dee9d8c644da4093caa117e97cbf150.jpg" },
    // Products from Home Page
    { id: 8, name: "The Brown louis Vuitton", category: "Bags", material: "Leather", price: 35000000, img: "https://i.pinimg.com/1200x/34/b7/c0/34b7c03d20fbdd628e141c6834bacd6a.jpg" },
    { id: 9, name: "Flower Applique Cap Sleeve", category: "Shirt", material: "Cotton", price: 2500000, img: "https://i.pinimg.com/1200x/2d/b6/2a/2db62aa07bb2e682d07f95b53c0aa6b8.jpg" },
    { id: 10, name: "Dior Diorissimo Vintage Flower", category: "Bags", material: "Canvas", price: 42000000, img: "https://i.pinimg.com/1200x/75/95/9a/75959a02a721662ec269f6b4df46892a.jpg" },
    { id: 11, name: "Tank Top Polkadot", category: "Shirt", material: "Cotton", price: 580000, img: "https://i.pinimg.com/736x/6b/19/dd/6b19dd66a91b9091ecac651262f62a81.jpg" },
    { id: 12, name: "Black Short Pants", category: "Pants", material: "Cotton", price: 195000, img: "https://i.pinimg.com/736x/ff/0c/50/ff0c502438dd06c2bae7c12439395178.jpg" },
    { id: 13, name: "Dark Brown Short-sleeved Shirt", category: "Shirt", material: "Cotton", price: 420000, img: "https://i.pinimg.com/1200x/14/50/c4/1450c4370485587662dbd32dd5997173.jpg" },
    { id: 14, name: "Star Print Parachute Pants", category: "Pants", material: "Parachute", price: 380000, img: "https://i.pinimg.com/736x/02/c4/7d/02c47d09612bcd4814a4ab178edad7a1.jpg" },
    { id: 15, name: "Classic Trench Coat", category: "Coat", material: "Leather", price: 18500000, img: "https://i.pinimg.com/1200x/81/b9/58/81b9585d45134a38934277e4cca77496.jpg" },
    { id: 16, name: "Minimalist Tote Bag", category: "Bags", material: "Leather", price: 21200000, img: "https://i.pinimg.com/1200x/75/7c/a7/757ca7b73b9e3e8bafe7c813a098441c.jpg" },
    { id: 17, name: "Flatshoes Ribbon", category: "Shoes", material: "Leather", price: 4500000, img: "https://i.pinimg.com/736x/29/26/aa/2926aaa8c9acfbf2703176239e99f87c.jpg" },
    { id: 18, name: "Linen Wide Leg Pants", category: "Pants", material: "Linen", price: 3200000, img: "https://i.pinimg.com/1200x/83/f6/ad/83f6ada86ceabaeedfff2cacb6034e81.jpg" },
    { id: 19, name: "Oversized Knit Sweater", category: "Sweater", material: "Knit", price: 4100000, img: "https://i.pinimg.com/1200x/cd/bc/9f/cdbc9f6bfeb97e3e665c3981e6ae728f.jpg" },
    { id: 20, name: "Knit Top Brown", category: "Shirt", material: "Cotton", price: 1800000, img: "https://i.pinimg.com/1200x/8f/45/04/8f45047b552790bbe2316ae0040e30d5.jpg" },
    { id: 21, name: "Elegant Silk One Set", category: "Shirt", material: "Silk", price: 500000, img: "https://i.pinimg.com/736x/5d/ef/9c/5def9c4cee1d9edbc4d75251d77aad48.jpg" }
];

// Helper function to get a product by ID
function getProductById(id) {
    return dbProducts.find(p => p.id === parseInt(id));
}
