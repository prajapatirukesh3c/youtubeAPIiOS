//
//  ViewController.swift
//  YTDemo
//
//  Created by Rukesh Prajapati on 7/11/17.
//  Copyright © 2017 callistos. All rights reserved.
//

import UIKit

/*class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
 
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
 
 /// <#Description#>
 override func viewDidLoad() {
 super.viewDidLoad()
 
 tblVideos.delegate = self
 tblVideos.dataSource = self
 searchTextField.delegate = self
 
 //        let nib = UINib(nibName: "VideosTableViewCell", bundle: nil)
 //        tblVideos.register(nib, forCellReuseIdentifier: "VideosTableViewCell")
 let nib = UINib(nibName: "VideosTableViewCell", bundle: nil)
 tblVideos.register(nib, forCellReuseIdentifier: "VideosTableViewCell")
 let nib2 = UINib(nibName: "ChannelTableViewCell", bundle: nil)
 tblVideos.register(nib2, forCellReuseIdentifier: "ChannelTableViewCell")
 
 getChannelDetails(useChannelIDParam: false)
 
 }
 
 override func didReceiveMemoryWarning() {
 super.didReceiveMemoryWarning()
 // Dispose of any resources that can be recreated.
 }
 
 func numberOfSectionsInTableView(tableView: UITableView) -> Int {
 return 1
 }
 
 
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 if segDisplayedContent.selectedSegmentIndex == 0 {
 return channelsDataArray.count
 }
 else {
 return videosArray.count
 }
 }
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 //  let cell = tableView.dequeueReusableCell(withIdentifier: "VideosTableViewCell", for: indexPath) as! VideosTableViewCell
 
 
 if segDisplayedContent.selectedSegmentIndex == 0{
 
 let cell = tableView.dequeueReusableCell(withIdentifier: "VideosTableViewCell", for: indexPath) as! VideosTableViewCell
 
 let channelDetails = channelsDataArray[indexPath.row]
 let url = NSURL(string: (channelDetails["thumbnail"] as! String))
 do {
 
 cell.videoImage.image =  try UIImage(data: Data(contentsOf: url! as URL))
 } catch {
 
 }
 
 cell.videoTitle.text = channelDetails["title"] as? String
 cell.videoDesc.text = channelDetails["description"] as? String
 return cell
 
 }
 else {
 
 let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell", for: indexPath) as! ChannelTableViewCell
 
 let vedioDetails = videosArray[indexPath.row]
 let url = NSURL(string: (vedioDetails["thumbnail"] as! String))
 do {
 
 cell.videoImage.image =  try UIImage(data: Data(contentsOf: url! as URL))
 } catch {
 
 }
 
 cell.videoLabel.text = vedioDetails["title"] as? String
 
 
 return cell
 }
 
 }
 
 
 @IBAction func changeContent(_ sender: UISegmentedControl) {
 tblVideos.reloadData()
 }
 
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 if segDisplayedContent.selectedSegmentIndex == 0 {
 // In this case the channels are the displayed content.
 // The videos of the selected channel should be fetched and displayed.
 
 // Switch the segmented control to "Videos".
 segDisplayedContent.selectedSegmentIndex = 1
 
 // Show the activity indicator.
 viewWait.isHidden = false
 
 // Remove all existing video details from the videosArray array.
 videosArray.removeAll(keepingCapacity: false)
 
 // Fetch the video details for the tapped channel.
 getVideosForChannelAtIndex(index: indexPath.row)
 }
 else {
 let storyboard = UIStoryboard(name: "Main", bundle: nil)
 let playerViewController = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
 playerViewController.videoID = videosArray[indexPath.row]["videoID"] as! String
 
 self.navigationController?.pushViewController(playerViewController, animated: true)
 
 
 
 
 }
 }
 
 func performGetRequest(targetURL: NSURL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: Error?) -> Void) {
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
 
 
 func getChannelDetails(useChannelIDParam: Bool) {
 var urlString: String!
 if !useChannelIDParam {
 urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
 }
 else {
 urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
 }
 
 let targetURL = NSURL(string: urlString)
 
 
 performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
 if HTTPStatusCode == 200 && error == nil {
 // Convert the JSON data to a dictionary.
 do {
 let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
 
 
 
 // Get the first dictionary item from the returned items (usually there's just one item).
 let items: AnyObject! = resultsDict["items"] as AnyObject!
 let firstItemDict = (items as! Array<AnyObject>)[0] as! Dictionary<String, AnyObject>
 
 // Get the snippet dictionary that contains the desired data.
 let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
 
 // Create a new dictionary to store only the values we care about.
 var desiredValuesDict: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
 desiredValuesDict["title"] = snippetDict["title"]
 desiredValuesDict["description"] = snippetDict["description"]
 desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
 
 // Save the channel's uploaded videos playlist ID.
 desiredValuesDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<String, AnyObject>)["relatedPlaylists"] as! Dictionary<String, AnyObject>)["uploads"]
 
 
 // Append the desiredValuesDict dictionary to the following array.
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
 
 // Get the selected channel's playlistID value from the channelsDataArray array and use it for fetching the proper video playlst.
 let playlistID = channelsDataArray[index]["playlistID"] as! String
 
 // Form the request URL string.
 let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(playlistID)&key=\(apiKey)"
 
 // Create a NSURL object based on the above string.
 let targetURL = NSURL(string: urlString)
 
 performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
 if HTTPStatusCode == 200 && error == nil {
 // Convert the JSON data into a dictionary.
 do {
 
 let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
 
 // Get all playlist items ("items" array).
 let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
 
 // Use a loop to go through all video items.
 for i in 0 ..< items.count {
 let playlistSnippetDict = (items[i] as Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
 
 // Initialize a new dictionary and store the data of interest.
 var desiredPlaylistItemDataDict = Dictionary<String, AnyObject>()
 
 desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
 desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
 desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<String, AnyObject>)["videoId"]
 
 // Append the desiredPlaylistItemDataDict dictionary to the videos array.
 self.videosArray.append(desiredPlaylistItemDataDict)
 
 // Reload the tableview.
 self.tblVideos.reloadData()
 }
 } catch {
 print(error.localizedDescription)
 }
 }else {
 print("HTTP Status Code = \(HTTPStatusCode)")
 print("Error while loading channel videos: \(String(describing: error))")
 }
 
 // Hide the activity indicator.
 self.viewWait.isHidden = true
 })
 }
 
 func textFieldShouldReturn(_ textField: UITextField) -> Bool {
 textField.resignFirstResponder()
 viewWait.isHidden = false
 
 // Specify the search type (channel, video).
 var type = "channel"
 channelsDataArray.removeAll(keepingCapacity: false)
 if segDisplayedContent.selectedSegmentIndex == 1 {
 type = "video"
 videosArray.removeAll(keepingCapacity: false)
 }
 let query = textField.text!
 let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(query)&type=\(type)&key=\(apiKey)"
 
 // urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
 // Create a NSURL object based on the above string.
 let targetURL = NSURL(string: urlString)
 
 performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
 if HTTPStatusCode == 200 && error == nil {
 // Convert the JSON data to a dictionary object.
 do {
 let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
 
 // Get all search result items ("items" array).
 let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
 
 // Loop through all search results and keep just the necessary data.
 for i in 0 ..< items.count {
 let snippetDict = items[i]["snippet"] as! Dictionary<String, AnyObject>
 
 // Gather the proper data depending on whether we're searching for channels or for videos.
 if self.segDisplayedContent.selectedSegmentIndex == 0 {
 // Keep the channel ID.
 self.desiredChannelsArray.append(snippetDict["channelId"] as! String)
 self.tblVideos.reloadData()
 }
 else {
 // Create a new dictionary to store the video details.
 var videoDetailsDict = Dictionary<String, AnyObject>()
 videoDetailsDict["title"] = snippetDict["title"]
 videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
 videoDetailsDict["videoID"] = (items[i]["id"] as! Dictionary<String, AnyObject>)["videoId"]
 
 // Append the desiredPlaylistItemDataDict dictionary to the videos array.
 self.videosArray.append(videoDetailsDict)
 
 // Reload the tableview.
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
 
 }
 else {
 print("HTTP Status Code = \(HTTPStatusCode)")
 print("Error while loading channel videos: \(String(describing: error))")
 }
 
 // Hide the activity indicator.
 self.viewWait.isHidden = true
 })
 
 
 return true
 }
 
 }
 */

class ViewController: UIViewController{
    
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
        //        let nib = UINib(nibName: "VideosTableViewCell", bundle: nil)
        //        tblVideos.register(nib, forCellReuseIdentifier: "VideosTableViewCell")
        let nib = UINib(nibName: "VideosTableViewCell", bundle: nil)
        tblVideos.register(nib, forCellReuseIdentifier: "VideosTableViewCell")
        let nib2 = UINib(nibName: "ChannelTableViewCell", bundle: nil)
        tblVideos.register(nib2, forCellReuseIdentifier: "ChannelTableViewCell")
        
        getChannelDetails(useChannelIDParam: false)
        
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
    
    
    func getChannelDetails(useChannelIDParam: Bool) {
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
                // Convert the JSON data to a dictionary.
                do {
                  
                  guard let data = data else {
                    return
                  }
                  guard let resultsDict = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject> else {
                    return
                  }
                    
                    
                    // Get the first dictionary item from the returned items (usually there's just one item).
                    let items: AnyObject! = resultsDict["items"] as AnyObject!
                    let firstItemDict = (items as! Array<AnyObject>)[0] as! Dictionary<String, AnyObject>
                    
                    // Get the snippet dictionary that contains the desired data.
                    let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
                    
                    // Create a new dictionary to store only the values we care about.
                    var desiredValuesDict: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
                    desiredValuesDict["title"] = snippetDict["title"]
                    desiredValuesDict["description"] = snippetDict["description"]
                    desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                    
                    // Save the channel's uploaded videos playlist ID.
                    desiredValuesDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<String, AnyObject>)["relatedPlaylists"] as! Dictionary<String, AnyObject>)["uploads"]
                    
                    
                    // Append the desiredValuesDict dictionary to the following array.
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
        
        // Get the selected channel's playlistID value from the channelsDataArray array and use it for fetching the proper video playlst.
        let playlistID = channelsDataArray[index]["playlistID"] as! String
        
        // Form the request URL string.
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(playlistID)&key=\(apiKey)"
        
        // Create a NSURL object based on the above string.
      guard let targetURL = NSURL(string: urlString) else {
        return
      }
        
        performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data into a dictionary.
                do {
                    
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
                    
                    // Get all playlist items ("items" array).
                    let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                    
                    // Use a loop to go through all video items.
                    for i in 0 ..< items.count {
                        let playlistSnippetDict = (items[i] as Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
                        
                        // Initialize a new dictionary and store the data of interest.
                        var desiredPlaylistItemDataDict = Dictionary<String, AnyObject>()
                        
                        desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
                        desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                        desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<String, AnyObject>)["videoId"]
                        
                        // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                        self.videosArray.append(desiredPlaylistItemDataDict)
                        
                        // Reload the tableview.
                        self.tblVideos.reloadData()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel videos: \(String(describing: error))")
            }
            
            // Hide the activity indicator.
            self.viewWait.isHidden = true
        })
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segDisplayedContent.selectedSegmentIndex == 0 {
            return channelsDataArray.count
        }
        else {
            return videosArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //  let cell = tableView.dequeueReusableCell(withIdentifier: "VideosTableViewCell", for: indexPath) as! VideosTableViewCell
        
        
        if segDisplayedContent.selectedSegmentIndex == 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideosTableViewCell", for: indexPath) as! VideosTableViewCell
            let channelDetails = channelsDataArray[indexPath.row]
            let url = NSURL(string: (channelDetails["thumbnail"] as! String))
            do {
                cell.videoImage.image =  try UIImage(data: Data(contentsOf: url! as URL))
            } catch {
            }
            cell.videoTitle.text = channelDetails["title"] as? String
            cell.videoDesc.text = channelDetails["description"] as? String
            return cell
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell", for: indexPath) as! ChannelTableViewCell
            let vedioDetails = videosArray[indexPath.row]
            let url = NSURL(string: (vedioDetails["thumbnail"] as! String))
            do {
                cell.videoImage.image =  try UIImage(data: Data(contentsOf: url! as URL))
            } catch {
                
            }
            cell.videoLabel.text = vedioDetails["title"] as? String
            return cell
        }
    }
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segDisplayedContent.selectedSegmentIndex == 0 {
            // In this case the channels are the displayed content.
            // The videos of the selected channel should be fetched and displayed.
            
            // Switch the segmented control to "Videos".
            segDisplayedContent.selectedSegmentIndex = 1
            
            // Show the activity indicator.
            viewWait.isHidden = false
            
            // Remove all existing video details from the videosArray array.
            videosArray.removeAll(keepingCapacity: false)
            
            // Fetch the video details for the tapped channel.
            getVideosForChannelAtIndex(index: indexPath.row)
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let playerViewController = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            playerViewController.videoID = videosArray[indexPath.row]["videoID"] as? String
            
            self.navigationController?.pushViewController(playerViewController, animated: true)
        }
    }
}

extension ViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewWait.isHidden = false
        
        // Specify the search type (channel, video).
        var type = "channel"
        channelsDataArray.removeAll(keepingCapacity: false)
        if segDisplayedContent.selectedSegmentIndex == 1 {
            type = "video"
            videosArray.removeAll(keepingCapacity: false)
        }
        let query = textField.text!
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(query)&type=\(type)&key=\(apiKey)"
        
        // urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        // Create a NSURL object based on the above string.
      let targetURL = NSURL(string: urlString)
        performGetRequest(targetURL: targetURL!, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data to a dictionary object.
                do {
                  guard let data = data else {
                    return
                  }
                  guard let resultsDict = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject> else {
                    return
                  }
                    
                    // Get all search result items ("items" array).
                    let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                    
                    // Loop through all search results and keep just the necessary data.
                    for i in 0 ..< items.count {
                        let snippetDict = items[i]["snippet"] as! Dictionary<String, AnyObject>
                        
                        // Gather the proper data depending on whether we're searching for channels or for videos.
                        if self.segDisplayedContent.selectedSegmentIndex == 0 {
                            // Keep the channel ID.
                            self.desiredChannelsArray.append(snippetDict["channelId"] as! String)
                            self.tblVideos.reloadData()
                        }
                        else {
                            // Create a new dictionary to store the video details.
                            var videoDetailsDict = Dictionary<String, AnyObject>()
                            videoDetailsDict["title"] = snippetDict["title"]
                            videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                            videoDetailsDict["videoID"] = (items[i]["id"] as! Dictionary<String, AnyObject>)["videoId"]
                            
                            // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                            self.videosArray.append(videoDetailsDict)
                            
                            // Reload the tableview.
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
                
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel videos: \(String(describing: error))")
            }
            
            // Hide the activity indicator.
            self.viewWait.isHidden = true
        })
        
        
        return true
    }
    
    
}


