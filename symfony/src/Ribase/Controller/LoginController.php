<?php

namespace Ribase\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class DefaultController extends Controller
{
    /**
     * @Route("/login", name="Login")
     */
    public function indexAction(Request $request)
    {

        $users = $this->userExist();

        if($users == 0){
            return $this->redirectToRoute('register', array(), 301);
        }

        // replace this example code with whatever you need
        return $this->render('security/login.html.twig');
    }

    private function userExist() {
        $repository = $this->getDoctrine()->getRepository('Ribase:User');

        $users = $repository->findAll();

        return count($users);

    }
}
