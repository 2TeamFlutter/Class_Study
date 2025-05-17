from fastapi import FastAPI, UploadFile, File, Form
# File : 파일의 handler 
# Form : front 에서 들어오는 data 를 하나의 form 으로 만들어서 서버에 주기 위해 (model 이 필요 없다.)
from fastapi.responses import Response
# multi progrem 을 쓰기 위한 Import (async)
import pymysql

app = FastAPI()

# MySQL server host
def connect():
    return pymysql.connect(
        host="127.0.0.1",
        user="root",
        password="qwer1234",
        db="python",
        charset="utf8"
    )

# ------------------------------------------------------------------------------------------------------- #
# text file 을 먼저 불러온 뒤 image 를 불러온다 (performance 를 위해!)
@app.get("/select")
async def select():
    conn = connect()
    curs = conn.cursor()
    curs.execute("SELECT seq, name, phone, address, relation FROM address ORDER BY name")
    rows = curs.fetchall()
    conn.close()
    result = [{'seq':row[0], 'name':row[1], 'phone':row[2], 'address':row[3], 'relation':row[4]}for row in rows]
    return {'results' : result}
# ------------------------------------------------------------------------------------------------------- #
# seq : 1번 일 경우 1번의 image 를 불러오는 방식
@app.get('/view/{seq}')
async def view(seq : int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("SELECT image From address WHERE seq = %s",(seq,)) # (seq) 로 하면 int type 이고 (seq,) 로 작성해야 tuple type 이다!
        row = curs.fetchone()
        conn.close()
        if row and row[0]:
            return Response(
                content = row[0],
                media_type="image/jpeg",
                # 캐시를 사용하면 빠를수는 있지만 업데이트를 해도 이전의 data 를 보여주게 되서 쓰지 않는다.
                # header 를 붙여서 날려주어야 data 로 인식한다!
                headers={"Cache-control" : "no-cache, no-store, must-revalidate"}
            )
        else:
            return {"result" : "No image found"}
    except Exception as e:
        print("Error :", e)
        return {"result" : "Error"}
# ------------------------------------------------------------------------------------------------------- #
# pip install python-multipart 를 해주어야 한다!
@app.post("/insert")
# Form : form 으로 받아옴 으로써 model 을 사용하지 않는다.
# (...) : flutter 의 required 와 같다.
# image : UploadFile 의 File 형식으로 따로 받아주어야 한다!
async def insert(name : str=Form(...), phone : str=Form(...), address: str=Form(...), relation : str=Form(...), file: UploadFile=File(...)):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = "INSERT INTO address (name, phone, address, relation, image) VALUES (%s,%s,%s,%s,%s)"
        curs.execute(sql, (name, phone, address, relation, image_data))
        conn.commit()
        conn.close()
        return {'result' : "OK"}
    except Exception as e :
        print("Error :", e)
        return {"result" : "Error"}
# ------------------------------------------------------------------------------------------------------- #
# image 를 바꾸지 않았을 때의 update
@app.post('/update')
async def update(seq: int=Form(...), name : str=Form(...), phone : str=Form(...), address : str=Form(...), relation : str=Form(...)):
    try :
        conn = connect()
        curs = conn.cursor()
        sql = "UPDATE address SET name=%s, phone=%s, address=%s, relation=%s WHERE seq=%s"
        curs.execute(sql, (name, phone, address, relation, seq))
        conn.commit()
        conn.close()
        return {"result" : "OK"}
    except Exception as e:
        print("ERROR :", e)
        return {"result" : "Error"}
# ------------------------------------------------------------------------------------------------------- #
# image 를 바꾼 상태에서의 update
@app.post("/update_with_image")
async def update_with_image(seq : int=Form(...),name : str=Form(...), phone : str=Form(...), address: str=Form(...), relation : str=Form(...), file: UploadFile=File(...)):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = "UPDATE address SET name=%s, phone=%s, address=%s, relation=%s, image=%s WHERE seq=%s"
        curs.execute(sql, (name, phone, address, relation, image_data, seq))
        conn.commit()
        conn.close()
        return {'result' : "OK"}
    except Exception as e :
        print("Error :", e)
        return {"result" : "Error"}
# ------------------------------------------------------------------------------------------------------- #
@app.delete("/delete/{seq}")
async def delete(seq : int):
    try :
        conn = connect()
        curs = conn.cursor()
        curs.execute("DELETE FROM address where seq=%s", (seq,))
        conn.commit()
        conn.close()
        return {'result' : "OK"}
    except Exception as e:
        print("Error :", e)
        return {'result' : 'Error'}
# ------------------------------------------------------------------------------------------------------- #



# Main 함수 : 제일 먼저 실행되는 함수.
# FastAPI server host
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
