import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';

class ProductParse extends StatefulWidget {
  const ProductParse({super.key});

  @override
  State<ProductParse> createState() => _ProductParseState();
}

class _ProductParseState extends State<ProductParse> {
  late Future<List<dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = loadJson();
  }

  //ler os dados do json sem isolate
  /*Future<List<dynamic>> loadJson() async{
    final jsonString = await DefaultAssetBundle.of(context)
      .loadString("assets/data.json");
    final parsed = json.decode(jsonString);
    return parsed['items'] as List<dynamic>;
  }*/

  //Usando Isolete
  Future<List<dynamic>> loadJson() async {
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString("assets/data.json");
    return await Isolate.run((){
      final parsed = json.decode(jsonString);
      return parsed['items'] as List<dynamic>;
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Parse de produtos"),),
      body: FutureBuilder<List<dynamic>>(
        future: _items,

        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }else if(snapshot.hasError){
            return Center(child: Text("Erro: ${snapshot.error}"),);
          }else{
            final products = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: products.length,
              itemBuilder: (context, index){
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      product['nome'], 
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(product['categoria']),
                    trailing: Text(
                      "R\$ ${product['preco'].toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}