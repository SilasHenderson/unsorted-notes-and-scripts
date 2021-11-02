let sp = (() => {

	/* - - - Wasm - - - */

	let code = 
	`
	00 61 73 6d  	      ;; MAGIC  
	01 00 00 00           ;; VERSION
	
	01 08 02              ;; TYPES size num 
	60 01 7f 00           ;; - kind=func, sig=1 i32 in, 0 out  
	60 00 00              ;; - kind=func, sig=0 in, 0 out  
	`;

	code = Uint8Array.from(code
		.replace(/;;.*\n/g, '')
		.trim()
		.split(/[\s+\n+]+/g)
		.map(x => Number('0x'+x))
	)

	let mod  = new WebAssembly.Module(code);
	let inst = new WebAssembly.Instance(mode,{});

	/* - - - JavaScript - - - */

	sp = {}
	
	sp._instance = null;
	sp._buffer   = null;
	sp._pointer  = 0;

	sp.Load = (array, type) => {

		let offset = sp._pointer

		let typed_array
		if (type == 'i32') {
			typed_array = new Int32Array(sp._buffer, offset, array)
		}
		if (type == 'f32') {
			typed_array = new Float32Array(sp._buffer, offset, array)
		}
		sp._pointer += 4*typed_array.length

		return [offset, typed_array]
	}

	sp.Parse = (sparse_array) => {
  
		let num_rows = 0;
		sparse_array.forEach(([row,col,val]) => {
			num_rows = Math.max(row+1, num_rows)
		});

		let row_size_data = new Array(num_rows).fill(0); 
		let col_data      = new Array(num_rows).fill([]);
		let val_data      = new Array(num_rows).fill([]);
		let lookup        = new Array(num_rows).fill({})

		sparse_array.forEach(([row,col,val]) => {
			size[row] += 1
			col[ row].push(col)
			val[ row].push(val)
		})

		col_data = col_data.flat()
		val_data = val_data.flat()

		for (let [row,item] = [0,0]; item < num_items; item++) {
			if (items < 0) {
				items = size_data[++row];
			}
			lookup[row][col] = col_data[item];
		} 
		return {size, col, val, lookup}
	}

	sp.Sparse = (sparse_array) => {

		let {size, col, val, lookup} = sp.Parse(sparse_array);
		
		let [size_offset, size_data] = sp.Load(size, 'i32')
		let [col_offset,  col_data]  = sp.Load(col,  'i32')
		let [val_offset,  val_data]  = sp.Load(val,  'f32')	

		let sparse = {

			offset:{
				size: size_offset,
				col:  col_offset,
				val:  val_offset,
			},
			data:{
				size: size_data,
				col:  col_data,
				val:  val_data
			},
			set: (row,col,val) => { 
				sparse.data.val[idx] = sparse.lookup[row][col]
			},
			get: (row,col) => { 
				return sparse.data.val[sparse.lookup[row][col]]
			}
		}
		return sparse
	}	

	sp.Vec = (array, type='f32') => {

		let [offset, data] = sp.Load(array, type);

		let vec = {
			offset: offset, 
			data:  data
		};
		return vec;
	}

	return sp
})()