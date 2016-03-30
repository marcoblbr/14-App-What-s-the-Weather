//
//  ViewController.swift
//  14 - App What's the Weather
//
//  Created by Marco Linhares on 6/18/15.
//  Copyright (c) 2015 Marco Linhares. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var labelResult: UILabel!
    
    @IBOutlet weak var textCity: UITextField!
    
    @IBAction func buttonFindCity(sender: AnyObject) {
        // faz sumir o teclado
        self.view.endEditing(true)
        
        if textCity.text == "" || textCity.text == nil {
            labelResult.text = "Please insert a city."
        } else {
            var city = textCity.text!
            
            labelResult.text = "Searching for weather in " + city + "..."
            
            city = city.stringByReplacingOccurrencesOfString(" ", withString: "-")
            
            city = "http://www.weather-forecast.com/locations/" + city + "/forecasts/latest"
            
            var url = NSURL (string: city)

            var html : NSString = ""
        
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
                if error != nil {
                    self.labelResult.text = "Error"

                } else {
                    // lê uma url do disco e guarda código em html
                    html = NSString (data: data, encoding: NSUTF8StringEncoding)!
                
                    if html.containsString("You may have mistyped the address") {
                        dispatch_async (dispatch_get_main_queue()) {
                            self.labelResult.text = "City not found. Try again!"
                        }
                    } else {
                        // parse vai pegar a string entre begin e end
                        var parse = self.getSubstring (html as String, begin: "<span class=\"phrase\">", end: "</span>")
                        
                        // \u{00B0} = símbolo de grau
                        parse = parse.stringByReplacingOccurrencesOfString("&deg;", withString: "\u{00B0}")

                        // é preciso dar um dispatch para a string atualizar pelo main do app
                        // caso não tivesse, o app iria retornar nil para o result pois os dados ainda não foram
                        // obtidos da internet antes do término da instrução. com o dispatch, assim que o dado
                        // for obtido, ele é atualizado na tela
                        dispatch_async (dispatch_get_main_queue()) {
                            self.labelResult.text! = parse!
                        }
                    }
                }
            }
            
            // o comando abaixo executa a declaração de closure do task acima
            task.resume()
        }
    }

    // retorna a string entre begin e end
    func getSubstring (fullString : String!, begin: String!, end: String!) -> String! {
        var str : [String]
        
        if fullString == nil {
            return nil
        } else if begin == nil && end != nil {
            str = fullString.componentsSeparatedByString (end)
            
            // sem início, basta retornar o começo da separação com o início
            return str [0]
        } else if begin != nil && end == nil {
            str = fullString.componentsSeparatedByString (begin)
            
            // sem final, a string do meio é 2a string depois de feita a separação
            return str [1]
        } else if begin == nil && end == nil {
            return fullString
        } else {
            // divide a string em um vetor separado pela string enviada por parâmetro
            str = fullString.componentsSeparatedByString (begin)
            
            // str [1] terá o resultado e é usado novamente para pegar o final da string
            str = str [1].componentsSeparatedByString (end)
            
            // o retorno será a string no meio
            return str [0]
        }
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // quando é apertado enter do teclado, o botão é chamado
        buttonFindCity(self)

        return true
    }
    
    // chamado quando a cena já foi carregada e vai aparecer pela 1a ou nas demais vezes
    override func viewWillAppear(animated: Bool) {
        textCity.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        labelResult.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
