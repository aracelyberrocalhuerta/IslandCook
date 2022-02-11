//
//  TVCGetAllRecipes.swift
//  IslandCook
//
//  Created by Xavi Giron on 9/2/22.
//

import UIKit

class TVCGetAllRecipes: UITableViewController {
    
    var decodeData: [Datos] = []
    let origen = "Server"
//    let origen = "Local"
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if origen == "Local" {
            var url = loadDataFromLocalUrl()
            decodeJson(url: url)
        }
        else {
            let url = loadDataFromremoteUrl()
            decodeJson(url: url)
        }
        
    }
    
//    Decodificamos archivo json
    
    func decodeJson(url: URL)
    {
        do
        {
            let decoder = JSONDecoder()
            let datosArchivo = try Data(contentsOf: url)
            
            decodeData = try decoder.decode([Datos].self, from: datosArchivo)
        }
        catch
        {
            print("Error, no se puede parsear el archivo")
        }
        
        
    }
    

//    Cargamos datos de nuestro json local
    
    func loadDataFromLocalUrl() -> URL
    {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            fatalError("No se encuentra el archivo JSON en el Bundle")
        }
        return url
    }
    
//    Cargamos datos de nuestro server
    
    func loadDataFromremoteUrl() -> URL
    {
        guard let url = URL(string: "https://island-cook.herokuapp.com/api/recipe") else {
            fatalError("No se encuentra el JSON en la ruta remota")
        }
        return url
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decodeData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let urlImg = decodeData[indexPath.row].picture_url

        // Configure the cell...
        cell.textLabel?.text = decodeData [indexPath.row].name
        cell.imageView?.downloaded(from: urlImg)

        return cell
    }

}

//Extensión de carga de la imágen de receta

extension UIImageView {
    
//    función de descarga de la imágen de receta
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
