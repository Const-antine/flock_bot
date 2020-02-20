import os
import sys

from flask import Flask, render_template, request, abort, url_for, jsonify
import sys

sys.path.insert(0, os.path.dirname(__file__))


#def application(environ, start_response):
tasks = [{}]
 
app = Flask(__name__)
application = app
@app.route('/tasks', methods = ['POST'])

def create_task():
    task = {
        'name': request.json['name'],
        'userId': request.json['userId']
    }


    tasks.append(task)
    f = open("output.txt", "w")
    for i in tasks:
        index = str(i)
        f.write(index + '\n')
    f.close()

    return jsonify({'task': tasks}), 200
