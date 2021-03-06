//==============================================================================
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler email: geonetwork@osgeo.org
//==============================================================================

package org.fao.geonet.services.metadata;

import jeeves.resources.dbms.Dbms;
import jeeves.utils.Log;

import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.MetadataIndexerProcessor;
import org.fao.geonet.util.ThreadUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

/**
 * Class that extends MetadataIndexerProcessor to reindex the metadata
 * changed in any of the Batch operation services
 */
public class BatchOpsMetadataReindexer extends MetadataIndexerProcessor {
	
	public class BatchOpsCallable implements Callable<Void> {
		private final String ids[];
		private final int beginIndex, count;
		private final DataManager dm;
		private final Dbms dbms;
	
		BatchOpsCallable(String ids[], int beginIndex, int count, DataManager dm, Dbms dbms) {
			this.ids = ids;
			this.beginIndex = beginIndex;
			this.count = count;
			this.dm = dm;
			this.dbms = dbms;
		}
		
		public Void call() throws Exception {
			for(int i=beginIndex; i<beginIndex+count; i++) {
                boolean workspace = false;
                dm.indexMetadataGroup(dbms, ids[i], workspace, true);
			}
			return null;
		}
	}
	
  Set<String> metadata;
	Dbms dbms;

  public BatchOpsMetadataReindexer(DataManager dm, Dbms dbms, Set<String> metadata) {
      super(dm);
			this.dbms = dbms;
      this.metadata = metadata;
  }

	public void process() throws Exception {
		int threadCount = ThreadUtils.getNumberOfThreads();

		ExecutorService executor = Executors.newFixedThreadPool(threadCount);

		String[] ids = new String[metadata.size()];
		int i = 0;
        for (String id : metadata) {
            ids[i++] = id;
        }

		int perThread;
		if (ids.length < threadCount) perThread = ids.length;
		else perThread = ids.length / threadCount;
		int index = 0;
        if (Log.isDebugEnabled(Geonet.THREADPOOL)) {
            Log.debug(Geonet.THREADPOOL, "BatchOperation on " + ids.length + " records and a threadCount of " + threadCount);
        }
		List<Future<Void>> submitList = new ArrayList<Future<Void>>();
		while(index < ids.length) {
			int start = index;
			int count = Math.min(perThread,ids.length-start);
			// create threads to process this chunk of ids
			Callable<Void> worker = new BatchOpsCallable(ids, start, count, dm, dbms);
			Future<Void> submit = executor.submit(worker);
	        if (Log.isDebugEnabled(Geonet.THREADPOOL)) {
	            Log.debug(Geonet.THREADPOOL, "Worker with for processing " + count + " ids");
	        }
			submitList.add(submit);
			index += count;
		}

		for (Future<Void> future : submitList) {
			try {
				Void o = future.get();
			} catch (InterruptedException e) {
				e.printStackTrace();
			} catch (ExecutionException e) {
				e.printStackTrace();
			}
		}
		executor.shutdown();
	}
}