//
//  DataPersistenceManeger.swift
//  Netflix
//
//  Created by Ios Developer on 14.11.2022.
//

import Foundation
import UIKit
import CoreData

//verileri indirme işlemi

class DataPersistenceManeger {
    
    enum DatabasError:Error{
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
    }
    
    static let shared = DataPersistenceManeger()
    
    func downloadTitleWith(model:Title, completion: @escaping (Result<Void,Error>) -> Void){
       
        //bağlam yöneticisiyle konusabilmemiz için gerekli olan satırlar
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        
        let context = appDelegate.persistentContainer.viewContext
        
        let item = TitleItem(context: context) // veritabanına kaydedilmesi gerek bir başlık ögesi oluşturduk
        //context menager kontrolinde bir title item oluşturuyoruz demek
        
        item.original_title = model.original_title
        item.id = Int64(model.id)
        item.original_name = model.original_name
        item.overview = model.overview
        item.media_type = model.media_type
        item.poster_path = model.poster_path
        item.release_date = model.release_date
        item.vote_count = Int64(model.vote_count)
        item.vote_average = model.vote_average
        
        //veritabanına kayıt için save yap
        do{
            try context.save()
            completion(.success(())) //void iletmemiz isteniyor
        }catch{
            completion(.failure(DatabasError.failedToSaveData))
        }
        
    }
    
    //veritabanından baslıkları alacak işlev
    func fetchingTitlesFromDataBase(completion: @escaping (Result<[TitleItem],Error>)->Void){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        
        let context = appDelegate.persistentContainer.viewContext
        
        //context menegare istekte buluncaz
        let request:NSFetchRequest<TitleItem>
        
        request = TitleItem.fetchRequest()
        
        do{
           let titles = try context.fetch(request) // veritabanından çek
            completion(.success(titles))
        }catch{
            completion(.failure(DatabasError.failedToFetchData))
        }
    }
    
    //veritabanından silme
    func deleteTitleWith(model:TitleItem,completion:@escaping (Result<Void,Error>)->Void){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(model) // silmek istiyorum diyor ve aşagıda do catch ile siliyor
        
        do{
           try context.save()
            completion(.success(()))
        }catch{
            completion(.failure(DatabasError.failedToDeleteData))
        }
        
    }
    
}

    
    
