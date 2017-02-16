<?php

namespace Ribase\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Security\Core\SecurityContextInterface;

class LoginController extends Controller
{
    /**
     * @Route("/login", name="Login")
     */
    public function indexAction(Request $request)
    {

        $users = $this->userExist();

        if($users == 0){
            return $this->redirectToRoute('Register', array(), 301);
        }

        $session = $request->getSession();

        // get the login error if there is one
        if ($request->attributes->has(SecurityContextInterface::AUTHENTICATION_ERROR)) {
            $error = $request->attributes->get(
                SecurityContextInterface::AUTHENTICATION_ERROR
            );
        } else {
            $error = $session->get(SecurityContextInterface::AUTHENTICATION_ERROR);
            $session->remove(SecurityContextInterface::AUTHENTICATION_ERROR);
        }

        if(!isset($error)){
            $error = 0;
        }

        return $this->render(
            $this->render('security/login.html.twig'),
            array(
                'error' => $error,
                'last_username' => $session->get(SecurityContextInterface::LAST_USERNAME)
            )
        );
    }

    private function userExist() {
        $repository = $this->getDoctrine()->getRepository('Ribase:User');

        $users = $repository->findAll();

        return count($users);

    }
}
