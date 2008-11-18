package org.gentatoo.util;

/*
 * Copyright 2008 memoComp, www.memocomp.de
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

import java.io.File;

import javax.servlet.ServletContext;

/**
 * This class provides several method for manging the cache folder for blobs.
 * 
 * @author jhoechstaedter
 *
 */
public class BlobCacheManager {

	/**
	 * Relative path to cache folder
	 */
	private String cacheFolder = "";
	
	/**
	 * singleton instance of BlobCacheManager
	 */
	private static BlobCacheManager instance;
	
	private ServletContext context;
	
	private BlobCacheManager(ServletContext context)
	{
		this.context = context;
		PropertyManager pm = PropertyManager.getInstance(context);
		cacheFolder = pm.getPropertyByName(pm.BLOB_CACHE_FOLDER);
	}
	
	/**
	 * Method cleares the whole cache folder
	 * @param context
	 */
	public synchronized void deleteWholeCacheFolder(){
		System.out.println("going to delete" + cacheFolder);
		deleteFolder(context.getRealPath(cacheFolder));
	}
	
	/**
	 * Method cleares one folder in cache folder
	 * @param context
	 * @param folder
	 */
	public synchronized void deleteCacheFolder(String folder){
		
		deleteFolder(context.getRealPath(cacheFolder) +"/" + folder);
	}
	
	/**
	 * Method cleares the given folder
	 * 
	 * @param cacheFolder
	 */
	private void deleteFolder(String path){		
		
		if(path != null)
		{
			File folder = new File(path);
			
			if(folder.exists() && folder.isDirectory())
			{
				File[] files = folder.listFiles();
				
				for(int i=0; i<files.length;i++)
				{	
					
					if(files[i].isDirectory())
					{
						deleteFolder(files[i].getAbsolutePath());
					}
					
					files[i].delete();	
				}
				folder.delete();	
			}
		}
	}

	/**
	 * returns inctance of BlobCacheManager
	 * @return
	 */
	public static synchronized BlobCacheManager getInstance(ServletContext context) {
		
		if(instance == null)
		{
			instance = new BlobCacheManager(context);
		}
		return instance;
	}
}
