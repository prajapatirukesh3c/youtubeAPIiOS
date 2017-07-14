//
//  ViewController.swift
//  YTDemo
//
//  Created by Rukesh Prajapati on 7/11/17.
//  Copyright © 2017 callistos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var videosArray: [[String: AnyObject]] = []
  var apiKey = "AIzaSyBLsZ4ZurTYWZMGDuEtn6C-6OmqgU5emE0"
  var desiredChannelsArray = ["Apple", "Google", "Microsoft"]
  var channelIndex = 0
  var channelsDataArray: [[String: AnyObject]] = []
  var selectedVideoIndex: Int!
  
  @IBOutlet weak var tblVideos: UITableView!
  @IBOutlet weak var viewWait: UIActivityIndicatorView!
  @IBOutlet weak var segDisplayedContent: UISegmentedControl!
  @IBOutlet weak var searchTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tblVideos.delegate = self
    tblVideos.dataSource = self
    searchTextField.delegate = self
    
    let nib = UINib(nibName: "ChannelTableViewCell", bundle: nil)
    tblVideos.register(nib, forCellReuseIdentifier: "ChannelTableViewCell")
    let nib2 = UINib(nibName: "VideoTableViewCell", bundle: nil)
    tblVideos.register(nib2, forCellReuseIdentifier: "VideoTableViewCell")
    
    getChannelDetails()
  }
  
  @IBAction func changeContent(_ sender: UISegmentedControl) {
    tblVideos.reloadData()
  }
  
  func performGetRequest(targetURL: NSURL, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: Error?) -> Void) {
    let request = NSMutableURLRequest(url: targetURL as URL)
    request.httpMethod = "GET"
    
    let sessionConfiguration = URLSessionConfiguration.default
    
    let session = URLSession(configuration: sessionConfiguration)
    
    let task = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data!, response: URLResponse!, error: Error!) -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        completion(data, (response as! HTTPURLResponse).statusCode, error)
      })
    })
    
    task.resume()
  }
  
  func getChannelDetails(useChannelIDParam: Bool = false) {
    var urlString: String!
    if !useChannelIDParam {
      urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
    }
    else {
      urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
    }
    
    let targetURL = NSURL(string: urlString)
    
    
    performGetRequest(targetURL: targetURL!, completion: { (data, HTTPStatusCode, error) -> Void in
      if HTTPStatusCode == 200 && error == nil {
        do {
          guard let data = data else {
            return
          }
          guard let resultsDict = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject> else {
            return
          }
          
          guard let items: AnyObject = resultsDict["items"] as AnyObject? else {
            return
          }
          
          let firstItemDict = (items as! Array<AnyObject>)[0] as! Dictionary<String, AnyObject>
          let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
          
          var desiredValuesDict: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
          desiredValuesDict["title"] = snippetDict["title"]
          desiredValuesDict["description"] = snippetDict["description"]
          desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
          
          desiredValuesDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<String, AnyObject>)["relatedPlaylists"] as! Dictionary<String, AnyObject>)["uploads"]
          
          self.channelsDataArray.append(desiredValuesDict)
          self.tblVideos.reloadData()
          
          // Load the next channel data (if exist).
          self.channelIndex += 1
          if self.channelIndex < self.desiredChannelsArray.count {
            self.getChannelDetails(useChannelIDParam: useChannelIDParam)
          }
          else {
            self.viewWait.isHidden = true
          }
          
        } catch {
          print(error.localizedDescription)
        }
        
      } else {
        print("HTTP Status Code channel = \(HTTPStatusCode)")
        print("Error while loading channel details: \(String(describing: error))")
      }
    })
  }
  
  func getVideosForChannelAtIndex(index: Int!) {
    let playlistID = channelsDataArray[index]["playlistID"] as! String
    
    let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(playlistID)&key=\(apiKey)"
    
    guard let targetURL = NSURL(string: urlString) else {
      return
    }
    
    performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
      if HTTPStatusCode == 200 && error == nil {
        do {
          guard let data = data else {
            return
          }
          guard let resultsDict = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject> else {
            return
          }
          
          guard let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as? Array<Dictionary<String, AnyObject>> else {
            return
          }
          for i in 0 ..< items.count {
            
            guard let playlistSnippetDict = (items[i] as Dictionary<String, AnyObject>)["snippet"] as? Dictionary<String, AnyObject> else {
              return
            }
            
            // Initialize a new dictionary and store the data of interest.
            var desiredPlaylistItemDataDict = Dictionary<String, AnyObject>()
            
            desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
            desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
            desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<String, AnyObject>)["videoId"]
           
            self.videosArray.append(desiredPlaylistItemDataDict)
            
            self.tblVideos.reloadData()
          }
        } catch {
          print(error.localizedDescription)
        }
      }else {
        print("HTTP Status Code = \(HTTPStatusCode)")
        print("Error while loading channel videos: \(String(describing: error))")
      }
      self.viewWait.isHidden = true
    })
  }
}

extension ViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if segDisplayedContent.selectedSegmentIndex == 0 {
      return channelsDataArray.count
    } else {
      return videosArray.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if segDisplayedContent.selectedSegmentIndex == 0{
      let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell", for: indexPath) as! ChannelTableViewCell
      let channelDetails = channelsDataArray[indexPath.row]
      let url = NSURL(string: (channelDetails["thumbnail"] as! String))
      do {
        guard let url = url else {
          return cell
        }
        cell.videoImage.image =  try UIImage(data: Data(contentsOf: url as URL))
      } catch {
        print(error)
      }
      cell.videoTitle.text = channelDetails["title"] as? String
      cell.videoDesc.text = channelDetails["description"] as? String
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell", for: indexPath) as! VideoTableViewCell
      let vedioDetails = videosArray[indexPath.row]
      let url = NSURL(string: (vedioDetails["thumbnail"] as! String))
      do {
        guard let url = url else {
          return cell
        }
        cell.videoImage.image =  try UIImage(data: Data(contentsOf: url as URL))
      } catch {
        print (error)
      }
      cell.videoLabel.text = vedioDetails["title"] as? String
      return cell
    }
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if segDisplayedContent.selectedSegmentIndex == 0 {
      segDisplayedContent.selectedSegmentIndex = 1
      viewWait.isHidden = false
      // Remove all existing video details from the videosArray array.
      videosArray.removeAll(keepingCapacity: false)
      
      // Fetch the video details for the tapped channel.
      getVideosForChannelAtIndex(index: indexPath.row)
    } else {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let playerViewController = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
      playerViewController.videoID = videosArray[indexPath.row]["videoID"] as? String
      
      self.navigationController?.pushViewController(playerViewController, animated: true)
    }
  }
}

extension ViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    viewWait.isHidden = false
    
    var type = "channel"
    channelsDataArray.removeAll(keepingCapacity: false)
    if segDisplayedContent.selectedSegmentIndex == 1 {
      type = "video"
      videosArray.removeAll(keepingCapacity: false)
    }
    
    let query = textField.text!
    let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(query)&type=\(type)&key=\(apiKey)"
    
    let targetURL = NSURL(string: urlString)
    performGetRequest(targetURL: targetURL!, completion: { (data, HTTPStatusCode, error) -> Void in
      if HTTPStatusCode == 200 && error == nil {
        do {
          guard let data = data else {
            return
          }
          guard let resultsDict = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject> else {
            return
          }
          let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
          for i in 0 ..< items.count {
            let snippetDict = items[i]["snippet"] as! Dictionary<String, AnyObject>
            
            if self.segDisplayedContent.selectedSegmentIndex == 0 {
              // Keep the channel ID.
              self.desiredChannelsArray.append(snippetDict["channelId"] as! String)
              self.tblVideos.reloadData()
            } else {
              // Create a new dictionary to store the video details.
              var videoDetailsDict = Dictionary<String, AnyObject>()
              videoDetailsDict["title"] = snippetDict["title"]
              videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
              videoDetailsDict["videoID"] = (items[i]["id"] as! Dictionary<String, AnyObject>)["videoId"]
              
              self.videosArray.append(videoDetailsDict)
              
              self.tblVideos.reloadData()
            }
          }
        } catch {
          print(error)
        }
        // Call the getChannelDetails(…) function to fetch the channels.
        if self.segDisplayedContent.selectedSegmentIndex == 0 {
          self.getChannelDetails(useChannelIDParam: true)
        }
      } else {
        print("HTTP Status Code = \(HTTPStatusCode)")
        print("Error while loading channel videos: \(String(describing: error))")
      }
      self.viewWait.isHidden = true
    })
    return true
  }
}
